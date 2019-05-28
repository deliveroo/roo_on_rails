require 'json/jwt'
require 'faraday'
require 'faraday_middleware'

module RooOnRails
  module Rack
    class PopulateEnvFromJWT
      UnacceptableKeyError = Class.new(RuntimeError)
      VALID_PREFIXES_KEY = 'VALID_IDENTITY_URL_PREFIXES'.freeze
      DEFAULT_MAPPED_URLS = {
        'https://test.deliveroo.co.uk/' => 'https://orderweb.rooenv-staging.io/',
        'https://deliveroo.co.uk/' => 'https://orderweb.deliverooapp.com/',
        'https://identity-staging.deliveroo.com/' => 'https://internal-identity.rooenv-staging.io/',
        'https://identity.deliveroo.com/' => 'https://internal-identity.deliverooapp.com/'
      }.freeze

      def self.configured?
        ENV[VALID_PREFIXES_KEY].present?
      end

      def initialize(app, logger:, skip_sig_verify: true, url_mappings: DEFAULT_MAPPED_URLS)
        @app = app
        @logger = logger
        @url_mappings = url_mappings
        @keys = @mapped_urls = {}

        if skip_sig_verify && non_prod?
          @logger.warn "JWTs signature verifification has been switched off in development."
          @verify_sigs = false
        else
          @verify_sigs = true
        end
      end

      def call(env)
        env['roo.identity'] = decode_authorization_header(env['HTTP_AUTHORIZATION'])
        @app.call(env)

      # Other exceptions will bubble up, allowing the higher middleware to return a 500, which is
      # intentional.
      rescue UnacceptableKeyError, JSON::JWT::Exception => e
        # Identifying user is clearly attempting to hack or has been given a totally incorrect
        # token, log this and flag as Forbidden, without executing the rest of the middleware stack.
        Raven.report_exception(e) if defined?(Raven)
        [401, {}, []]
      end

      private

      def key_prefixes
        return [] unless self.class.configured?
        ENV[VALID_PREFIXES_KEY].split(',')
      end

      def non_prod?
        if ENV['RACK_ENV'].nil?
          @logger.warn "Your RACK_ENV isn't set. You probably want it set to 'development' in dev."
        end

        %w(development test).include? ENV['RACK_ENV']
      end

      # @raise [UnacceptableKeyError,Faraday::Error,OpenSSL::OpenSSLError] From `#public_key`
      # @raise [JSON::JWT::Exception] Bubble ups from `JSON::JWT.decode`
      # @return [JSON::JWT] The list of claims this header makes by way of a JWS token. Will be an
      #   empty hash for invalid or absent tokens.
      def decode_authorization_header(header_value)
        return JSON::JWT.new unless (header_value || '').starts_with?('Bearer ')
        jws_token = header_value[7..-1]

        JSON::JWT.decode(jws_token, :skip_verification).tap do |jwt|
          jwt.verify!(public_key(jwt.header[:jku])) if @verify_sigs
        end
      end

      def acceptable_key?(key_url)
        return false if key_url.nil?
        key_prefixes.any? { |acceptable| key_url.starts_with?(acceptable) }
      end

      # @raise [UnacceptableKeyError] When the key URL is not from a trusted location
      # @raise [Faraday::Error] When the JWK at the given URL is not retrievable for some reason.
      #   See: https://github.com/lostisland/faraday/blob/master/lib/faraday/error.rb
      # @return [JSON::JWK] The JWK for the specified URL
      def public_key(key_url)
        unless acceptable_key?(key_url)
          raise UnacceptableKeyError, "#{key_url} is not a valid Deliveroo Key URL"
        end

        # NB. don't use ||= memoization, or this middleware can be attacked by
        # being asked to decode large numbers of non-existant key-ids, each of
        # which would fill the @keys hash with a tuple.
        return @keys[key_url] if @keys.key?(key_url)

        @logger.info "Downloading identity public key from #{key_url}"
        json = http_request.get(mapped_url(key_url)).body
        @keys[key_url] = JSON::JWK.new(json)
      rescue Faraday::ParsingError
        raise JSON::JWT::InvalidFormat, 'Downloaded JWK is not a valid JSON file'
      end

      def http_request
        Faraday.new do |conf|
          conf.response :json
          conf.response :raise_error
          conf.request :json

          conf.adapter Faraday.default_adapter
        end
      end

      # Allows us to use internal URLs instead of external ones where appropriate
      def mapped_url(url)
        return @mapped_urls[url] unless @mapped_urls[url].nil?

        @url_mappings.each do |prefix, replacement|
          next unless url.starts_with?(prefix)
          mapped = url.sub(prefix, replacement)
          @mapped_urls[url] = mapped
          return mapped
        end

        url
      end
    end
  end
end
