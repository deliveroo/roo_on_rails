require 'active_support/concern'
require 'action_controller/metal/http_authentication'

module RooOnRails
  module Concerns
    # This concern allows API authentication in a consistent manner.
    #
    # If a service connects with basic auth using the username "service" then the
    # `SERVICE_CLIENT_KEY` environment variable must have the given password as one of
    # the comma separated strings within it or a 403 will be raised.
    #
    # @example: Any service with an acceptable key can access routes
    #
    #     class ThingController < ApplicationController
    #       include RooOnRails::Concerns::RequireApiKey
    #       require_api_key
    #
    #       # etc
    #     end
    #
    # @example: Only the specified clients can access specific routes in this controller
    #
    #     class ThingController < ApplicationController
    #       include RooOnRails::Concerns::RequireApiKey
    #       require_api_key(only_services: :my_service, only: :create)
    #
    #       # etc
    #     end
    module RequireApiKey
      extend ActiveSupport::Concern
      include ActionController::HttpAuthentication::Basic::ControllerMethods

      attr_reader :current_client

      module ClassMethods
        # Declares that routes on the controller must have access credentials specified
        # in the request that match the approparite environment variables.
        #
        # @param :only_services (#to_s,Array<#to_s>) Restricts the services which will be accepted
        # @see AbstractController::Callbacks::ClassMethods#before_action for additional scoping opts
        def require_api_key(only_services: nil, **options)
          before_action(**options) do
            authenticate_or_request_with_http_basic('Authenitcation required') do |service_name, client_key|
              Authenticator.new([*only_services]).valid?(service_name, client_key).tap do |is_valid|
                @current_client = OpenStruct.new(name: service_name).freeze if is_valid
              end
            end
          end
        end
      end

      # This functionality pulled out into a new class for testability
      class Authenticator
        def initialize(whitelisted_clients)
          @whitelisted_clients = whitelisted_clients.map(&:to_s)
        end

        def valid?(service_name, client_key)
          return false unless whitelisted?(service_name)

          NewRelic::Agent.add_custom_attributes(httpBasicUserId: service_name) if defined?(NewRelic)
          ClientApiKeys.instance.valid?(service_name, client_key)
        end

        private

        def whitelisted?(service_name)
          return true if @whitelisted_clients.empty?
          @whitelisted_clients.include?(service_name)
        end
      end

      class ClientApiKeys
        include Singleton

        CLIENT_KEY_NAME_SUFFIX_REGEX = /_CLIENT_KEY\Z/

        def initialize
          @cache = ENV.select { |key| key =~ CLIENT_KEY_NAME_SUFFIX_REGEX }
                      .map { |k, v| [service_name(k), parse_client_keys(v)] }
                      .to_h
                      .freeze
        end

        def valid?(service_name, client_key)
          return false if service_name.to_s.empty? || client_key.to_s.empty?

          client_keys = @cache[normalize(service_name)]
          return false unless client_keys
          client_keys.include?(client_key)
        end

        private

        def service_name(client_key_name)
          normalize(client_key_name.sub(CLIENT_KEY_NAME_SUFFIX_REGEX, ''))
        end

        def normalize(service_name)
          service_name.upcase.gsub(/[^A-Z0-9]+/, '_')
        end

        def parse_client_keys(str)
          (str || '').split(',').map(&:strip).to_set.freeze
        end
      end
    end
  end
end
