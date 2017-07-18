require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/papertrail/token'

module RooOnRails
  module Checks
    module Papertrail
      # Check for a configured log destination in Papertrail.
      #
      # Input context
      # - papertrail.client: a connected Papertrail client
      #
      # Output context:
      # - papertrail.dest.host, .port: the destination logging host
      class LogDestinationExists < Base
        requires Token

        # The shared log destination
        NAME = 'default'.freeze

        def intro
          "Checking for log destination #{bold NAME}..."
        end

        def call
          data = context.papertrail.client.list_destinations.find { |h|
            h['syslog']['description'] == NAME
          }

          fail! "Log destination #{bold NAME} not found" if data.nil?

          context.papertrail!.dest!.host = data['syslog']['hostname']
          context.papertrail!.dest!.port = data['syslog']['port']

          pass "logging to #{context.papertrail.dest.host}:#{context.papertrail.dest.port}"
        end
      end
    end
  end
end
