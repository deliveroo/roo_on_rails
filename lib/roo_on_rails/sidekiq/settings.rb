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

      class << self
        def queues
          @queues ||= permitted_latency_values.sort_by(&:last).map(&:first).freeze
        end

        def concurrency
          ENV.fetch('SIDEKIQ_THREADS', 25)
        end

        def permitted_latency_values
          @permitted_latency_values ||= ENV.key?('SIDEKIQ_QUEUES') ? env_queue_latency_values.freeze : DEFAULT_QUEUE_LATENCY_VALUES
        end

        private

        def env_queue_latency_values
          {}.tap do |hash|
            ENV['SIDEKIQ_QUEUES'].split(',').each do |entry|
              queue_entry = entry.strip
              if DEFAULT_QUEUE_LATENCY_VALUES.key?(queue_entry)
                queue_name = queue_entry
                hash[queue_name] = DEFAULT_QUEUE_LATENCY_VALUES[queue_entry]
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
      end
    end
  end
end
