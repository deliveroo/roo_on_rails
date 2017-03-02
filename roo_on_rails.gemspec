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
  spec.add_runtime_dependency 'newrelic_rpm', '~> 3.17'
  spec.add_runtime_dependency 'rails', '~> 5.0'
  spec.add_runtime_dependency 'platform-api', '~> 0.8'
  spec.add_runtime_dependency 'hashie', '~> 3.4'
  spec.add_runtime_dependency 'octokit'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'thor', '~> 0.19'
  spec.add_development_dependency 'pry-byebug'
end
