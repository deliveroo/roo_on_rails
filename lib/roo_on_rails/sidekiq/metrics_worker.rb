require 'sidekiq/api'
require 'roo_on_rails/sidekiq/queue_latency'
require 'roo_on_rails/sidekiq/process_scaling'
require 'roo_on_rails/sidekiq/settings'
require 'roo_on_rails/statsd'

# Reports Sidekiq queue metrics for queues configured within the current Sidekiq process
# i.e. queues returned by `RooOnRails::Sidekiq::Settings.queues`

module RooOnRails
  module Sidekiq
    class MetricsWorker
      include ::Sidekiq::Worker

      sidekiq_options queue: 'monitoring', retry: false

      def perform
        RooOnRails.statsd.batch do |stats|
          queues = fetch_queues
          queue_stats(stats, queues)
          process_stats(stats, queues)
        end
      end

      private

      def fetch_queues
        [].tap do |array|
          ::Sidekiq::Queue.all.each do |q|
            array << QueueLatency.new(q) if Settings.queues.include?(q.name.to_s)
          end
        end
      end

      def queue_stats(stats, queues)
        queues.each do |queue|
          tags = ["queue:#{queue.name}"]
          stats.gauge('jobs.queue.size', queue.size, tags: tags)
          stats.gauge('jobs.queue.latency', queue.latency, tags: tags)
          stats.gauge('jobs.queue.normalised_latency', queue.normalised_latency, tags: tags)
        end
      end

      def process_stats(stats, queues)
        process_stats = ProcessScaling.new(queues)
        stats.gauge('jobs.processes.max_normalised_latency', process_stats.max_normalised_latency)
        stats.gauge('jobs.processes.requested', process_stats.requested_processes)
        stats.gauge('jobs.processes.current', process_stats.current_processes)
      end
    end
  end
end
