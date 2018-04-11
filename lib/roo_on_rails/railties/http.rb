module RooOnRails
  module Railties
    class HTTP < Rails::Railtie
      initializer 'roo_on_rails.http' do |app|
        Rails.logger.with initializer: 'roo_on_rails.http' do |log|
          log.debug 'loading'

          require 'rack/timeout/base'
          require 'rack/ssl-enforcer'
          require 'roo_on_rails/rack/safe_timeouts'

          ::Rack::Timeout.service_timeout = ENV.fetch('RACK_SERVICE_TIMEOUT', 15).to_i
          ::Rack::Timeout.wait_timeout = ENV.fetch('RACK_WAIT_TIMEOUT', 30).to_i
          ::Rack::Timeout::Logger.level = ::Logger::WARN

          app.config.middleware.insert_before(
            ::Rack::Runtime,
            ::Rack::Timeout
          )

          middleware_to_insert_before = Rails::VERSION::MAJOR < 4 ? ::ActionDispatch::Cookies : ::Rack::Head

          # This needs to be inserted low in the stack, before Rails returns the
          # thread-current connection to the pool.
          if defined?(ActiveRecord)
            app.config.middleware.insert_before(
              middleware_to_insert_before,
              RooOnRails::Rack::SafeTimeouts
            )
          end

          if ENV.fetch('ROO_ON_RAILS_RACK_DEFLATE', 'YES').to_s =~ /\A(YES|TRUE|ON|1)\Z/i
            app.config.middleware.use ::Rack::Deflater
          end
        end
      end
    end
  end
end
