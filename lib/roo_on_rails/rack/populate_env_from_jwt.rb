require 'json/jwt'
require 'faraday'
require 'faraday_middleware'

module RooOnRails
  module Rack
    class PopulateEnvFromJWT
      UnnacceptableKeyError = Class.new(RuntimeError)
      VALID_JWK_URL_PREFIXES = [
        'https://www.deliveroo.com/identity-keys/',
        'https://identity.deliveroo.com/identity-keys/'
      ].freeze

      def initialize(app, logger:)
        @app = app
        @keys = {}
        @logger = logger

        if development?
          @logger.warn "JWTs will not have their signatures checked, you're in development mode."
        end
      end

      def call(env)
        env['roo.identity'] = decode_authorization_header(env['HTTP_AUTHORIZATION'])
        @app.call(env)

      # Other exceptions will bubble up, allowing the higher middleware to return a 500, which is
      # intentional.
      rescue UnnacceptableKeyError, JSON::JWT::Exception => e
        # Identifying user is clearly attempting to hack or has been given a totally incorrect
        # token, log this and flag as Forbidden, without executing the rest of the middleware stack.
        ::NewRelic::Agent.notice_error(e) if defined?(NewRelic)
        [403, {}, []]
      end

      private

      def development?
        if ENV['RACK_ENV'].nil?
          @logger.warn "Your RACK_ENV isn't set. You probably want it set to 'development' in dev."
        end

        ENV['RACK_ENV'] == 'development'
      end

      # @raise [UnnacceptableKeyError,Faraday::Error,OpenSSL::OpenSSLError] From `#public_key`
      # @raise [JSON::JWT::Exception] Bubble ups from `JSON::JWT.decode`
      # @return [JSON::JWT] The list of claims this header makes by way of a JWS token. Will be an
      #   empty hash for invalid or absent tokens.
      def decode_authorization_header(header_value)
        return JSON::JWT.new unless (header_value || '').starts_with?('Bearer ')
        jws_token = header_value[7..-1]

        JSON::JWT.decode(jws_token, :skip_verification).tap do |jwt|
          jwt.verify!(public_key(jwt.header[:jku])) unless development?
        end
      end

      def acceptable_key?(key_url)
        return false if key_url.nil?
        VALID_JWK_URL_PREFIXES.any? { |acceptable| key_url.starts_with?(acceptable) }
      end

      # @raise [UnnacceptableKeyError] When the key URL is not from a trusted location
      # @raise [Faraday::Error] When the JWK at the given URL is not retrievable for some reason.
      #   See: https://github.com/lostisland/faraday/blob/master/lib/faraday/error.rb
      # @return [JSON::JWK] The JWK for the specified URL
      def public_key(key_url)
        unless acceptable_key?(key_url)
          raise UnnacceptableKeyError, "#{key_url} is not a valid Deliveroo Key URL"
        end

        # NB. don't use ||= memoization, or this middleware can be attacked by
        # being asked to decode large numbers of non-existant key-ids, each of
        # which would fill the @keys hash with a tuple.
        return @keys[key_url] if @keys.key?(key_url)

        @logger.info "Downloading identity public key from #{key_url}"
        json = http_request.get(key_url).body
        @keys[key_url] = JSON::JWK.new(json)
      rescue Faraday::ParsingError
        raise JSON::JWT::InvalidFormat, 'Downloaded JWK is not a valid JSON file'
      end

      def http_request
        Faraday.new do |conf|
          conf.response :json
          conf.response :raise_error
          conf.request :json
          conf.use FaradayMiddleware::FollowRedirects, limit: 3

          conf.adapter Faraday.default_adapter
        end
      end
    end
  end
end
