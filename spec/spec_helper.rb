require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require 'pry-byebug'
require 'memfs'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

RSpec.configure do |config|
  rails_version = Gem::Version.new(`rails --version`.match(/[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?/)[0])
  config.filter_run_excluding rails_min_version: (lambda do |_, meta|
    Gem::Version.new(meta[:rails_min_version]) > rails_version
  end)

  config.around(:each, memfs: true) do |example|
    MemFs.activate { example.run }
  end
end
