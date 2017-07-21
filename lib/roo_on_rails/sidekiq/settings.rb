require_relative './queue_latency'

module RooOnRails
  module Sidekiq
    class Settings

      DEFAULT_QUEUE_LATENCY_VALUES = {
        'monitoring' => 10.seconds.to_i,
        'realtime' => 10.seconds.to_i,
        'within1minute' => 1.minute.to_i,
        'within5minutes' => 5.minutes.to_i,
        'within30minutes' => 30.minutes.to_i,
        'within1hour' => 1.hour.to_i,
        'within1day' => 1.day.to_i,
        'default' => 1.day.to_i
      }.freeze

      def self.queues
        @queues ||= QueueLatency.permitted_latency_values.sort_by(&:last).map(&:first).freeze
      end

      def self.concurrency
        ENV.fetch('SIDEKIQ_THREADS', 25)
      end
    end
  end
end
