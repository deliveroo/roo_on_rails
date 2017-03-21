# Returns stats on the current SLA performance of queues in a sidekiq instance.
# Assumes workers are not bound to queues
require 'sidekiq/api'
require 'active_support'
require 'active_support/core_ext/numeric'
module RooOnRails
  module SidekiqSlaMetric
    def self.queue
      queues = ::Sidekiq::Queue.all.map { |q| SidekiqQueueMetrics.new(q) }
      global_stats = SidekiqWorkerCount.new(queues)
      global_stats.requested_processes
    end

    class SidekiqQueueMetrics
      extend Forwardable
      def_delegators :@queue, :size, :latency, :name
      attr_reader :queue

      def initialize(queue)
        @queue = queue
      end

      def normalised_latency
        metric = queue.latency.to_f / permitted_latency
        metric.round(3)
      end

      def permitted_latency
        prefix, number, unit = queue.name.partition(/[0-9]+/)
        case prefix
        when 'monitoring', 'realtime' then 10.seconds
        when 'default' then 1.day
        when 'within' then number.to_i.public_send(unit.to_sym)
        else raise "Cannot determine permitted latency for queue #{queue.name}"
        end
      end
    end

    class SidekiqWorkerCount
      def initialize(metrics)
        @metrics = metrics
      end

      def current_processes
        Sidekiq::ProcessSet.new.count
      end

      def max_normalised_latency
        @metrics.any? ? @metrics.map(&:normalised_latency).max : 0
      end

      def requested_processes
        if max_normalised_latency > increasing_latency
          current_processes + 1
        elsif max_normalised_latency < decreasing_latency
          [current_processes - 1, 1].max
        else
          current_processes
        end
      end

      protected

      def increasing_latency
        ENV.fetch('WORKER_INCREASE_THRESHOLD', 0.5).to_f
      end

      def decreasing_latency
        ENV.fetch('WORKER_DECREASE_THRESHOLD', 0.1).to_f
      end
    end
  end
end
