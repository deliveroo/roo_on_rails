require 'sidekiq/api'

module RooOnRails
  module Sidekiq
    class ProcessScaling
      def initialize(queue_latencies)
        @queue_latencies = queue_latencies
      end

      def current_processes
        ::Sidekiq::ProcessSet.new.count
      end

      def max_normalised_latency
        @queue_latencies.any? ? @queue_latencies.map(&:normalised_latency).max : 0
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
