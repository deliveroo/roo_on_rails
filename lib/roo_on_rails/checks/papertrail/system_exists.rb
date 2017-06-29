require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/heroku/token'
require 'roo_on_rails/checks/papertrail/token'
require 'roo_on_rails/checks/papertrail/drain_exists'

module RooOnRails
  module Checks
    module Papertrail
      # Checks that the app is declared in Papertrail
      #
      # Input context
      # - heroku.api_client: a connected PlatformAPI client
      # - heroku.app.{env}: an existing app name.
      # - papertrail.system_name.{env}: a Papertrail system name / token
      # - papertrail.client
      # - papertrail.dest.host, .port
      #
      # Output context:
      # - FIXME
      class SystemExists < EnvSpecific
        requires Heroku::AppExists
        requires Heroku::Token
        requires Token
        requires DrainExists
        requires LogDestinationExists

        def intro
          "Checking that #{bold app_name} is logging to Papertrail"
        end

        def call
          data = context.papertrail.client.list_systems.find { |h|
            h['hostname'] == system_token
          }
          fail! "no system with token '#{system_token}' found" if data.nil?

          if data.syslog.hostname != context.papertrail.dest.host ||
              data.syslog.port != context.papertrail.dest.port
            final_fail! "system found, but is listening to #{data.syslog.hostname}:#{data.syslog.port} instead of #{context.papertrail.dest.host}:#{context.papertrail.dest.port}"
          end

          pass "found system for token #{system_token}"
        end

        def fix
        end

        private

        def system_token
          context.papertrail.system_name[env]
        end

        def app_name
          context.heroku.app[env]
        end
      end
    end
  end
end
