require 'datadog/statsd'
require 'singleton'

module RooOnRails
  class Statsd
    include Singleton

    attr_reader :client

    def initialize
      @client = defined?(::STATSD) ? ::STATSD : ::Datadog::Statsd.new(host, port, tags: tags)
    end

    private

    def host
      ENV.fetch('STATSD_HOST', 'localhost')
    end

    def port
      ENV.fetch('STATSD_PORT', 8125)
    end

    def tags
      [
        "env:#{ENV.fetch('STATSD_ENV', 'unknown')}",
        "source:#{ENV.fetch('DYNO', 'unknown')}",
        "app:#{ENV.fetch('HEROKU_APP_NAME', 'unknown')}"
      ]
    end
  end

  def self.statsd
    RooOnRails::Statsd.instance.client
  end
end
