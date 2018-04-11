require 'sidekiq'
require 'roo_on_rails/config'
require 'roo_on_rails/statsd'
require 'roo_on_rails/sidekiq/settings'
require 'roo_on_rails/sidekiq/sla_metric'

module RooOnRails
  module Railties
    class Sidekiq < Rails::Railtie
      initializer 'roo_on_rails.sidekiq' do |app|
        Rails.logger.with initializer: 'roo_on_rails.sidekiq' do |log|
          
          unless RooOnRails::Config.sidekiq_enabled?
            log.debug 'skipping'
            next
          end

          log.debug 'loading'
         
          config_sidekiq
          config_sidekiq_metrics
        end
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
        Rails.logger.warn 'Sidekiq metrics unavailable without Sidekiq Pro'
      end
    end
  end
end
