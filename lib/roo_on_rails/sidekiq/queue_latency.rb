require 'active_support/core_ext/numeric'

module RooOnRails
  module Sidekiq
    class QueueLatency
      extend Forwardable

      def self.permitted_latency_values
        @permitted_latency_values ||= Hash.new do |hash, queue_name|
					hash[queue_name] = begin
						case queue_name
						when 'monitoring', 'realtime'
							10.seconds.to_i
						when 'default'
							1.day.to_i
						when /\Awithin\d+.+\z/
							_, number, unit = queue_name.partition(/\d+/)
							number.strip.to_i.public_send(unit.strip).to_i
						else
							ENV.fetch('SIDEKIQ_QUEUES', '').split(',').reduce(nil) do |result, entry|
								entry = entry.strip
								next result unless entry.start_with?(queue_name)
								_, number, unit = entry.split(':').last.partition(/\d+/)
								number.strip.to_i.public_send(unit.strip).to_i
							end
						end
					end
        end
      end

      def_delegators :@queue, :size, :latency, :name
      attr_reader :queue

      def initialize(queue)
        @queue = queue
      end

      def normalised_latency
				queue.latency.fdiv(permitted_latency).round(3)
      end

      private

      def permitted_latency
        self.class.permitted_latency_values[queue.name] ||
          raise("Cannot determine permitted latency for queue #{queue.name}")
      end
    end
  end
end
