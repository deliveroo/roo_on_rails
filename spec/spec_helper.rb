require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require 'pry-byebug'
require 'memfs'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

RSpec.configure do |config|
  config.around(:each, memfs: true) do |example|
    MemFs.activate { example.run }
  end
end
