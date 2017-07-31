require 'hashie'
require 'pathname'

module RooOnRails
  class Config < Hashie::Mash
    class << self
      def load
        path = Pathname '.roo_on_rails.yml'
        path.exist? ? super(path) : new
      end

      def sidekiq_enabled?
        enabled? 'SIDEKIQ_ENABLED'
      end

      def google_auth_enabled?
        enabled? 'GOOGLE_AUTH_ENABLED', default: false
      end

      def google_auth_path_prefix
        ENV.fetch('GOOGLE_AUTH_PATH_PREFIX')
      end

      def google_auth_controller
        ENV.fetch('GOOGLE_AUTH_CONTROLLER')
      end

      def routemaster_enabled?
        enabled? 'ROUTEMASTER_ENABLED', default: false
      end

      private

      ENABLED_PATTERN = /\A(YES|TRUE|ON|1)\Z/i

      def enabled?(var, default: 'true')
        ENABLED_PATTERN === ENV.fetch(var, default).to_s
      end
    end
  end
end
