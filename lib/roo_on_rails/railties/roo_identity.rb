require 'roo_on_rails/rack/populate_env_from_jwt'

module RooOnRails
  module Railties
    class RooIdentity < Rails::Railtie
      initializer 'roo_on_rails.roo_identity.middleware' do |app|
        if RooOnRails::Rack::PopulateEnvFromJWT.configured?
          Rails.logger.debug '[roo_on_rails.roo_identity.middleware] loading'
          _add_middleware(app, Rails.logger)
        else
          # rubocop:disable Metrics/LineLength
          Rails.logger.warn '[roo_on_rails.roo_identity.middleware] not configured, roo.identity will be unavailable'
          # rubocop:enable
        end
      end

      private

      def _add_middleware(app, log)
        app.config.middleware.use RooOnRails::Rack::PopulateEnvFromJWT, logger: log
      rescue LoadError
        # rubocop:disable Metrics/LineLength
        log.error '[roo_on_rails.roo_identity.middleware] the json-jwt gem is not in the bundle so Roo Identity will not be available'
        # rubocop:enable
      end
    end
  end
end
