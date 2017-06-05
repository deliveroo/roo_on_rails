require 'sidekiq'
require 'roo_on_rails/statsd'
require 'roo_on_rails/sidekiq/settings'
require 'roo_on_rails/sidekiq/sla_metric'

module RooOnRails
  module Railties
    class Sidekiq < Rails::Railtie
      initializer 'roo_on_rails.sidekiq' do |app|
        require 'hirefire-resource'
        $stderr.puts 'initializer roo_on_rails.sidekiq'
        break unless ENV.fetch('SIDEKIQ_ENABLED', 'true').to_s =~ /\A(YES|TRUE|ON|1)\Z/i
        config_sidekiq
        config_sidekiq_metrics
        config_hirefire(app)
      end

      def config_hirefire(app)
        unless ENV['HIREFIRE_TOKEN']
          warn 'No HIREFIRE_TOKEN token set, auto scaling not enabled'
          return
        end
        add_middleware(app)
      end

      def config_sidekiq
        ::Sidekiq.configure_server do |x|
          x.options[:concurrency] = RooOnRails::Sidekiq::Settings.concurrency.to_i
          x.options[:queues] = RooOnRails::Sidekiq::Settings.queues
        end
      end

      def config_sidekiq_metrics
        require 'sidekiq/middleware/server/statsd'

        ::Sidekiq.configure_server do |x|
          x.server_middleware do |chain|
            chain.add ::Sidekiq::Middleware::Server::Statsd, client: RooOnRails.statsd
          end
        end
      rescue LoadError
        $stderr.puts 'Sidekiq metrics unavailable without Sidekiq Pro'
      end

      def add_middleware(app)
        $stderr.puts 'HIREFIRE_TOKEN set'
        app.middleware.use HireFire::Middleware
        HireFire::Resource.configure do |config|
          config.dyno(:worker) do
            RooOnRails::Sidekiq::SlaMetric.queue
          end
        end
      end
    end
  end
end
