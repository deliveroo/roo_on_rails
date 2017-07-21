require_relative './queue_latency'

module RooOnRails
  module Sidekiq
    class Settings
      def self.queues
        @queues ||= QueueLatency.permitted_latency_values.sort_by(&:last).map(&:first).freeze
      end

      def self.concurrency
        ENV.fetch('SIDEKIQ_THREADS', 25)
      end
    end
  end
end
