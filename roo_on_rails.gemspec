# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roo_on_rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'roo_on_rails'
  spec.version       = RooOnRails::VERSION
  spec.authors       = ['Julien Letessier']
  spec.email         = ['julien.letessier@gmail.com']

  spec.summary       = 'Scaffolding for building services'
  spec.description   = 'Scaffolding for building services'
  spec.homepage      = 'https://github.com/deliveroo/roo_on_rails'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'dotenv-rails', '~> 2.1'
  spec.add_runtime_dependency 'newrelic_rpm'
  spec.add_runtime_dependency 'rails', '>= 3.2.22', '< 5.3'
  spec.add_runtime_dependency 'rack-timeout'
  spec.add_runtime_dependency 'dogstatsd-ruby'
  spec.add_runtime_dependency 'faraday'
  spec.add_runtime_dependency 'faraday_middleware'
  spec.add_runtime_dependency 'json-jwt', '~> 1.8'

  # Only required for opt-in functionality
  spec.add_development_dependency 'sidekiq'
  spec.add_development_dependency 'routemaster-client'

  # Only required for the checks functionality
  spec.add_development_dependency 'octokit'

  # Development gems
  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'thor', '~> 0.19'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'memfs'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rspec-its'
end
