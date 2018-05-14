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
        "release:#{release_id}",
        "app:#{app_name}"
      ]
    end

    def env_name
      ENV['STATSD_ENV'] || ENV['HOPPER_ECS_CLUSTER_NAME'] || 'unknown'
    end

    # Identifies a specific source container by type (e.g. web, worker)
    # and unique UUID.
    #
    def source_name
      container_name = ENV.fetch('HOPPER_ECS_CONTAINER_NAME', 'unknown')
      container_id   = ENV.fetch('HOPPER_ECS_TASK_ID', 'unknown')
      [container_name, container_id].join('.')
    end

    # Identifies a specific hopper release. Namespaced by runtime env.
    #
    def release_id
      if platform_env && hopper_release_id
        ['hopper', platform_env, hopper_release_id].join('.')
      else
        "unknown"
      end
    end

    def platform_env
      ENV['HOPPER_ECS_CLUSTER_NAME']
    end

    def hopper_release_id
      ENV['HOPPER_RELEASE_ID']
    end

    def app_name
      ENV['STATSD_APP_NAME'] || hopper_app_name || 'unknown'
    end

    def hopper_app_name
      app_name = ENV['HOPPER_APP_NAME']
      return unless app_name && platform_env
      [app_name, platform_env].join('-')
    end
  end

  def self.statsd
    RooOnRails::Statsd.instance.client
  end
end
