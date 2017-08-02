require 'roo_on_rails/config'

module RooOnRails
  module Railties
    class Routemaster < Rails::Railtie
      initializer 'roo_on_rails.routemaster' do
        next unless Config.routemaster_enabled?

        $stderr.puts 'initializer roo_on_rails.routemaster'

        abort 'Aborting: ROOBUS_URL and ROOBUS_UUID are required' if roobus_credentials_blank?

        require 'routemaster/client'

        ::Routemaster::Client.configure do |config|
          config.url = roobus_url
          config.uuid = roobus_uuid
        end
      end

      private

      def roobus_credentials_blank?
        roobus_url.blank? && roobus_uuid.blank?
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
