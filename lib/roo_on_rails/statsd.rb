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
        "env:#{env_name}",
        "source:#{source_name}",
        "app:#{app_name}"
      ]
    end

    def env_name
      ENV['STATSD_ENV'] || ENV['HOPPER_ECS_CLUSTER_NAME'] || 'unknown'
    end

    def source_name
      ENV['DYNO'] || ENV['HOSTNAME'] || 'unknown'
    end

    def app_name
      ENV['STATSD_APP_NAME'] || ENV['HEROKU_APP_NAME'] || hopper_app_name || 'unknown'
    end

    def hopper_app_name
      app_name = ENV['HOPPER_APP_NAME']
      cluster_name = ENV['HOPPER_ECS_CLUSTER_NAME']
      return unless app_name && cluster_name
      [app_name, cluster_name].join('-')
    end
  end

  def self.statsd
    RooOnRails::Statsd.instance.client
  end
end
