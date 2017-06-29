require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/heroku/token'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/papertrail/log_destination_exists'

module RooOnRails
  module Checks
    module Papertrail
      # Check if a Heroku app is setup to a log drain to Papertrail
      #
      # Input context
      # - heroku.api_client: a connected PlatformAPI client
      # - heroku.app.{env}: an app name.
      # - papertrail.dest.host, .port
      #
      # Output context:
      # - papertrail.system_name.{env}: the drain token for this app, aka.
      #   "system name" in Papertrail. Looks like "d.{uuid}".
      class DrainExists < EnvSpecific
        requires Heroku::Token
        requires Heroku::AppExists
        requires LogDestinationExists

        def intro
          "Checking for Papertrail drain on #{bold app_name}..."
        end

        def call
          # find the PT drain
          data = client.log_drain.list(app_name).
            select { |h| h['url'] =~ /papertrailapp/ }
          fail! 'no Papertrail drain found' if data.empty?
          fail! 'multiple Papertrail drains found' if data.length > 1

          data = data.first
          fail! "app is draining to #{data['url']} instead of #{papertrail_url}" if data['url'] != papertrail_url

          pass "found drain setup with token #{data['token']}"
          context.papertrail.system_name![env] = data['token']
        end

        def fix
          client.log_drain.create(app_name, url: papertrail_url)
        end

        private

        def app_name
          context.heroku.app[env]
        end

        def client
          context.heroku.api_client
        end

        def papertrail_url
          format 'syslog+tls://%s:%s', 
            context.papertrail.dest.host,
            context.papertrail.dest.port
        end
      end
    end
  end
end
