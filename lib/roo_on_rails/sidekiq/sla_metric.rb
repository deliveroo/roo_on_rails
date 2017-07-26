require 'sidekiq/api'
require 'roo_on_rails/sidekiq/queue_latency'
require 'roo_on_rails/sidekiq/process_scaling'

module RooOnRails
  module Sidekiq
    # Returns stats on the current SLA performance of queues in a Sidekiq instance.
    #
    # Only returns stats for queues being processed by current Sidekiq process
    class SlaMetric
      def self.queue
        queues = QueueLatency.queues
        global_stats = ProcessScaling.new(queues)
        global_stats.requested_processes
      end
    end
  end
end
