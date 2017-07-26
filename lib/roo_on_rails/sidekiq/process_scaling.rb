require 'sidekiq/api'

module RooOnRails
  module Sidekiq
    class ProcessScaling
      WORKER_INCREASE_THRESHOLD = ENV.fetch('WORKER_INCREASE_THRESHOLD', 0.5).to_f
      WORKER_DECREASE_THRESHOLD = ENV.fetch('WORKER_DECREASE_THRESHOLD', 0.1).to_f
      private_constant :WORKER_INCREASE_THRESHOLD
      private_constant :WORKER_DECREASE_THRESHOLD

      def initialize(queue_latencies)
        @queue_latencies = queue_latencies
        @queue_names = @queue_latencies.map(&:name)
      end

      def current_processes
        ::Sidekiq::ProcessSet.new.count do |process|
          process['quiet'] == 'false' &&
          @queue_names.any? do |queue_name|
            process['queues'].include?(queue_name)
          end
        end
      end

      def max_normalised_latency
          @queue_latencies.any? ? @queue_latencies.map(&:normalised_latency).max.to_f : 0.0
      end

      def requested_processes
        if max_normalised_latency > WORKER_INCREASE_THRESHOLD
          current_processes + 1
        elsif max_normalised_latency < WORKER_DECREASE_THRESHOLD
          [current_processes - 1, 1].max
        else
          current_processes
        end
      end
    end
  end
end
