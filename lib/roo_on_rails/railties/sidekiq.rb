module RooOnRails
  module Railties
    class Sidekiq < Rails::Railtie
      initializer 'roo_on_rails.sidekiq' do |app|
        require 'hirefire-resource'
        $stderr.puts 'initializer roo_on_rails.sidekiq'
        break unless ENV.fetch('SIDEKIQ_ENABLED', 'true').to_s =~ /\A(YES|TRUE|ON|1)\Z/i
        config_hirefire(app)
      end

      def config_hirefire(app)
        unless ENV['HIREFIRE_TOKEN']
          warn 'No HIREFIRE_TOKEN token set, auto scaling not enabled'
          return
        end
        add_middleware(app)
      end

      def add_middleware(app)
        $stderr.puts 'HIREFIRE_TOKEN set'
        app.middleware.use HireFire::Middleware
        HireFire::Resource.configure do |config|
          config.dyno(:worker) do
            RooOnRails::SidekiqSla.queue
          end
        end
      end
    end
  end
end
