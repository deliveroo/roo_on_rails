require 'active_support/core_ext/numeric'

module RooOnRails
  module Sidekiq
    class QueueLatency
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

      private

      def permitted_latency
        entries = ENV.fetch('SIDEKIQ_PERMITTED_LATENCY_VALUES', '').split(',')
        entry = entries.find { |e| e.start_with?(queue.name) }
        return default_queue_permitted_latency unless entry
        _, duration, unit = entry.split(':')
        duration.to_i.public_send(unit).to_i
      end

      def default_queue_permitted_latency
        prefix, number, unit = queue.name.partition(/[0-9]+/)
        case prefix
        when 'monitoring', 'realtime' then 10.seconds.to_i
        when 'default' then 1.day.to_i
        when 'within' then number.to_i.public_send(unit.to_sym).to_i
        else raise "Cannot determine permitted latency for queue #{queue.name}"
        end
      end
    end
  end
end
