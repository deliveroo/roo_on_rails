require 'active_support'
require 'active_support/core_ext/numeric'
require 'roo_on_rails/sidekiq/settings'

module RooOnRails
  module Sidekiq
    class QueueLatency
      extend Forwardable

      def_delegators :@queue, :size, :latency, :name
      attr_reader :queue

      def self.queues
        ::Sidekiq::Queue.all.each_with_object([]) do |q, array|
          array << new(q) if Settings.queues.include?(q.name.to_s)
        end
      end

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
