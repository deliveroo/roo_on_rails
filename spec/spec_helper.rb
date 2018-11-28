ENV['LOG_LEVEL'] ||= 'info'

require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require 'pry-byebug'
require 'memfs'
require 'rspec/its'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

RSpec.configure do |config|
  require_relative './support/env_helpers'
  config.include(EnvHelpers)

  require_relative './support/sidekiq_queue_helpers'
  config.include(SidekiqQueueHelpers)

  config.filter_run(focus: true) unless ENV['CONTINUOUS_INTEGRATION']
  config.run_all_when_everything_filtered = true

  config.filter_run_excluding rails_min_version: (lambda { |_, meta|
    require 'rails'
    Gem::Version.new(meta[:rails_min_version]) >= Gem::Version.new(Rails::VERSION::STRING)
  })

  config.around(:each, memfs: true) do |example|
    MemFs.activate { example.run }
  end

  config.before(:each, webmock: true) { require 'webmock/rspec' ; WebMock.enable! }
  config.after(:each,  webmock: true) { WebMock.disable! }
end
