require 'sidekiq'
require 'roo_on_rails/config'
require 'roo_on_rails/statsd'
require 'roo_on_rails/sidekiq/settings'
require 'roo_on_rails/sidekiq/sla_metric'

module RooOnRails
  module Railties
    class SidekiqIntegration < Rails::Railtie
      initializer 'roo_on_rails.sidekiq' do |app|
        unless RooOnRails::Config.sidekiq_enabled?
          Rails.logger.debug '[roo_on_rails.sidekiq] skipping'
          next
        end

        Rails.logger.debug '[roo_on_rails.sidekiq] loading'

        config_sidekiq
        config_sidekiq_metrics
      end

      def config_sidekiq
        ::Sidekiq.configure_server do |x|
          x.options[:concurrency] = RooOnRails::Sidekiq::Settings.concurrency.to_i
          x.options[:queues] = RooOnRails::Sidekiq::Settings.queues
        end
      end

      def config_sidekiq_metrics
        # https://github.com/mperham/sidekiq/wiki/Pro-Metrics
        require 'sidekiq-pro'
        ::Sidekiq::Pro.dogstatsd = -> { RooOnRails.statsd }

        ::Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            require 'sidekiq/middleware/server/statsd'
            chain.add ::Sidekiq::Middleware::Server::Statsd
          end
        end
      rescue LoadError
        Rails.logger.warn 'Sidekiq metrics unavailable without Sidekiq Pro'
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
