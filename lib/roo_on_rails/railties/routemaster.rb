require 'roo_on_rails/config'

module RooOnRails
  module Railties
    class Routemaster < Rails::Railtie
      initializer 'roo_on_rails.routemaster' do
        next unless Config.routemaster_enabled?

        $stderr.puts 'initializer roo_on_rails.routemaster'

        abort 'Aborting: ROUTEMASTER_URL & ROUTEMASTER_UUID are required' if bus_credentials_blank?

        require 'routemaster/client'

        ::Routemaster::Client.configure do |config|
          config.url = routemaster_url
          config.uuid = routemaster_uuid
        end
      end

      private

      def bus_credentials_blank?
        routemaster_url.blank? && routemaster_uuid.blank?
      end

      def routemaster_url
        ENV.fetch('ROUTEMASTER_URL')
      end

      def routemaster_uuid
        ENV.fetch('ROUTEMASTER_UUID')
      end
    end
  end
end
