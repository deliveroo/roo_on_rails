require 'roo_on_rails/config'

module RooOnRails
  module Railties
    class Routemaster < Rails::Railtie
      initializer 'roo_on_rails.routemaster' do
        Rails.logger.with initializer: 'roo_on_rails.routemaster' do |log|
          next unless Config.routemaster_enabled?
          log.debug 'loading'

          abort 'Aborting: ROUTEMASTER_URL and ROUTEMASTER_UUID are required' if bus_details_missing?

          require 'routemaster/client'

          ::Routemaster::Client.configure do |config|
            config.url = routemaster_url
            config.uuid = routemaster_uuid
            config.verify_ssl = routemaster_verify_ssl
          end
        end
      end

      private

      def bus_details_missing?
        routemaster_url.blank? || routemaster_uuid.blank?
      end

      def routemaster_url
        ENV.fetch('ROUTEMASTER_URL')
      end

      def routemaster_uuid
        ENV.fetch('ROUTEMASTER_UUID')
      end

      def routemaster_verify_ssl
        ENV.fetch('ROUTEMASTER_VERIFY_SSL', 'true') != 'false'
      end
    end
  end
end
