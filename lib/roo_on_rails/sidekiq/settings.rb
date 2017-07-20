module RooOnRails
  module Sidekiq
    class Settings
      DEFAULT_QUEUES = %w(
        monitoring
        realtime
        within1minute
        within5minutes
        within30minutes
        within1hour
        within1day
        default
      ).freeze

      def self.queues
				ENV.fetch('SIDEKIQ_QUEUES', '').split(',').map { |queue_entry|
					queue_entry.split(':').first.strip
				}.presence || DEFAULT_QUEUES
      end

      def self.concurrency
        ENV.fetch('SIDEKIQ_THREADS', 25)
      end
    end
  end
end
