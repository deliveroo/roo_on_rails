require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/git/origin'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/heroku/metrics_bridge_configured'
require 'uri'

module RooOnRails
  module Checks
    module Heroku
      # Checks that the app is configured to send its logs to the Heroku-Datadog
      # metrics bridge.
      #
      # Input context
      # - heroku.api_client: a connected PlatformAPI client
      # - heroku.app.{env}: an existing app name.
      # - heroku.metric_bridge_token.{env}: the password for the metrics bridge
      class DrainsMetrics < EnvSpecific
        requires Heroku::AppExists, MetricsBridgeConfigured

        def intro
          "Checking for metrics drain on #{bold app_name}"
        end

        def call
          url = client.log_drain.list(app_name).
                map { |h| h['url'] }.
                find { |u| u.include? MetricsBridgeConfigured::BRIDGE_APP }

          fail! 'No matching drain found' if url.nil?
          final_fail! 'Misconfigured drain found' if url != drain_uri
          pass 'Drain is connected'
        end

        private

        def fix
          client.log_drain.create(app_name, url: drain_uri)
        end

        def drain_uri
          'https://%s:%s@%s.herokuapp.com' % [
            app_name,
            context.heroku.metric_bridge_token![env],
            MetricsBridgeConfigured::BRIDGE_APP
          ]
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
