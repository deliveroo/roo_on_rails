require_relative './env_helpers'

module SidekiqQueueHelpers
  include EnvHelpers

  def stub_queues(value)
    reset_queues
    stub_config_var('SIDEKIQ_QUEUES', value)
  end

  def reset_queues
    require 'roo_on_rails/sidekiq/settings'
    RooOnRails::Sidekiq::Settings.queues
    RooOnRails::Sidekiq::Settings.permitted_latency_values
    RooOnRails::Sidekiq::Settings.remove_instance_variable(:@queues)
    RooOnRails::Sidekiq::Settings.remove_instance_variable(:@permitted_latency_values)
  end
end
