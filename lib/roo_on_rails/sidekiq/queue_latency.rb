require 'active_support/core_ext/numeric'
require_relative './settings'

module RooOnRails
  module Sidekiq
    class QueueLatency
      extend Forwardable

      class << self
        def permitted_latency_values
          @permitted_latency_values ||= ENV.key?('SIDEKIQ_QUEUES') ? extract_queues_from_env.freeze : default_values
        end

        private

        def extract_queues_from_env
          {}.tap do |hash|
            ENV['SIDEKIQ_QUEUES'].split(',').each do |entry|
              queue_entry = entry.strip
              if default_values.key?(queue_entry)
                queue_name = queue_entry
                hash[queue_name] = default_values[queue_entry]
              elsif queue_entry.match(/\Awithin\d+.+\z/)
                _, number, unit = queue_entry.partition(/\d+/)
                hash[queue_entry] = number.to_i.public_send(unit.strip).to_i
              elsif queue_entry.include?(':')
                queue_name, latency_info = queue_entry.split(':')
                _, number, unit = latency_info.partition(/\d+/)
                hash[queue_name] = number.to_i.public_send(unit.strip).to_i
              end
            end
          end
        end

        def default_values
          Settings::DEFAULT_QUEUE_LATENCY_VALUES
        end
      end

      def_delegators :@queue, :size, :latency, :name
      attr_reader :queue

      def initialize(queue)
        @queue = queue
      end

      def normalised_latency
        permitted_latency = self.class.permitted_latency_values[queue.name]
        if permitted_latency
          queue.latency.fdiv(permitted_latency).round(3)
        else
          raise("Cannot determine permitted latency for queue #{queue.name}")
        end
      end
    end
  end
end
