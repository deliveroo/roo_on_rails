require 'active_support/core_ext/numeric'
require_relative './settings'

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
        permitted_latency = Settings.permitted_latency_values[queue.name]
        return queue.latency.fdiv(permitted_latency).round(3) if permitted_latency
        raise("Cannot determine permitted latency for queue #{queue.name}")
      end
    end
  end
end
