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
        env_key = 'SIDEKIQ_QUEUES'
        return DEFAULT_QUEUES unless ENV.key?(env_key)
        ENV[env_key].split(',').map do |queue_entry|
          queue_entry.split(':').first.strip
        end
      end

      def self.concurrency
        ENV.fetch('SIDEKIQ_THREADS', 25)
      end
    end
  end
end
