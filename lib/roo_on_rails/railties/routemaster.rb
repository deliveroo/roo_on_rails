require 'roo_on_rails/config'

module RooOnRails
  module Railties
    class Routemaster < Rails::Railtie
      initializer 'roo_on_rails.routemaster' do
        return unless routemaster_and_roobus_enabled?

        require 'routemaster/client'

        Routemaster::Client.configure do |config|
          config.url = roobus_url
          config.uuid = roobus_uuid
        end
      end

      private

      def routemaster_and_roobus_enabled?
        Config.routemaster_enabled? && roobus_url && roobus_uuid
      end

      def roobus_url
        ENV.fetch('ROOBUS_URL')
      end

      def roobus_uuid
        ENV.fetch('ROOBUS_UUID')
      end
    end
  end
end
