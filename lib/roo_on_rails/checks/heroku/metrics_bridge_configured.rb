require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/git/origin'
require 'roo_on_rails/checks/heroku/app_exists'
require 'securerandom'
require 'set'

module RooOnRails
  module Checks
    module Heroku
      # Checks that the Heroku-Datadog metrics bridge is configured to accept
      # logs from the app.
      #
      # Input context
      # - heroku.api_client: a connected PlatformAPI client
      # - heroku.app.{env}: an existing app name.
      #
      # Output context:
      # - heroku.metric_bridge_token.{env}: the password for the metrics bridge
      class MetricsBridgeConfigured < EnvSpecific
        requires Heroku::AppExists

        BRIDGE_APP = 'roo-dd-bridge-production'.freeze

        def intro
          'Checking whether metrics bridge is configured...'
        end

        def call
          config = current_config
          names = config[app_list_var].split(',')

          fail! 'Bridge does not allow this app'        unless names.include? app_name
          fail! 'Bridge lacks credentials for this app' unless config[token_var]
          fail! 'Bridge lacks tags for this app'        unless config[tags_var]

          pass "Bridge is configured for #{bold app_name}"
          context.heroku.metric_bridge_token![env] = config[token_var]
        end

        private

        def fix
          app_list = Set.new current_config.fetch(app_list_var, '').split(',')
          app_list << app_name
          client.config_var.update(
            BRIDGE_APP,
            tags_var     => "app:#{app_name}",
            token_var    => SecureRandom.hex(16),
            app_list_var => app_list.to_a.join(',')
          )
        rescue Excon::Error::Forbidden
          fail! "You are missing 'operate' permissions for #{bold BRIDGE_APP}"
        end

        def current_config
          client.config_var.info_for_app(BRIDGE_APP)
        rescue Excon::Error::Forbidden
          fail! "You are missing 'deploy' permissions for #{bold BRIDGE_APP}"
        end

        def app_list_var
          'ALLOWED_APPS'
        end

        def tags_var
          '%s_TAGS' % app_name.upcase
        end

        def token_var
          '%s_PASSWORD' % app_name.upcase
        end

        def app_name
          context.heroku.app[env]
        end

        def client
          context.heroku.api_client
        end
      end
    end
  end
end
