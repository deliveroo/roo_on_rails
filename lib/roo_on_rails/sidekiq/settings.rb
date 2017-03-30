module RooOnRails
  module Sidekiq
    class Settings
      def self.queues
        %w(
          monitoring
          realtime
          within1minute
          within5minutes
          within30minutes
          within1hour
          within1day
        ).freeze
      end

      def self.concurrency
        ENV.fetch('SIDEKIQ_THREADS', 25)
      end
    end
  end
end
