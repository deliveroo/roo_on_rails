module RooOnRails
  module Railties
    class HTTP < Rails::Railtie
      initializer 'roo_on_rails.http' do |app|
        $stderr.puts 'initializer roo_on_rails.http'
        require 'rack/timeout/base'
        require 'rack/ssl-enforcer'

        require 'roo_on_rails/rack/safe_timeouts'

        ::Rack::Timeout.service_timeout = ENV.fetch('RACK_SERVICE_TIMEOUT', 15).to_i
        ::Rack::Timeout.wait_timeout = ENV.fetch('RACK_WAIT_TIMEOUT', 30).to_i
        ::Rack::Timeout::Logger.level = Logger::WARN

        app.config.middleware.insert_before(
          ::Rack::Runtime,
          ::Rack::Timeout
        )

        middlewares = app.config.middleware.to_a.map { |c| c.klass.to_s }
        middlewares.each { |p| puts p.klass.to_s }
        
        middleware_to_insert_before = middlewares.include?('Rack::Head') ? ::Rack::Head : ::ActionDispatch::Cookies

        # This needs to be inserted low in the stack, before Rails returns the
        # thread-current connection to the pool.
        app.config.middleware.insert_before(
          middleware_to_insert_before,
          RooOnRails::Rack::SafeTimeouts
        )

        if ENV.fetch('ROO_ON_RAILS_RACK_DEFLATE', 'YES').to_s =~ /\A(YES|TRUE|ON|1)\Z/i
          app.config.middleware.use ::Rack::Deflater
        end

        # Don't use SslEnforcer in test environment as it breaks Capybara
        unless Rails.env.test?
          app.config.middleware.insert_before(
            middleware_to_insert_before,
            ::Rack::SslEnforcer
          )
        end
      end
    end
  end
end
