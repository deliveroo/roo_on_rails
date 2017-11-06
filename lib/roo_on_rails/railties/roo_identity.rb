require 'roo_on_rails/config'

module RooOnRails
  module Railties
    class RooIdentity < Rails::Railtie
      initializer 'roo_on_rails.roo_identity.middleware' do |app|
        Rails.logger.with initializer: 'roo_on_rails.roo_identity' do |log|
          log.debug 'loading'
          _add_middleware(app, log)
        end
      end

      private

      def _add_middleware(app, log)
        require 'roo_on_rails/rack/populate_env_from_jwt'

        app.config.middleware.use RooOnRails::Rack::PopulateEnvFromJWT, logger: log
      rescue LoadError
        log.error 'the json-jwt gem is not in the bundle so Roo Identity will not be available'
      end
    end
  end
end
