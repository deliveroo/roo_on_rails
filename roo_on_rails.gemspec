# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roo_on_rails/version'

Gem::Specification.new do |spec|
  spec.name          = "roo_on_rails"
  spec.version       = RooOnRails::VERSION
  spec.authors       = ["Julien Letessier"]
  spec.email         = ["julien.letessier@gmail.com"]

  spec.summary       = %q{Scaffolding for building services}
  spec.description   = %q{Scaffolding for building services}
  spec.homepage      = 'https://github.com/deliveroo/roo_on_rails'
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'dotenv-rails', '~> 2.1'
  spec.add_runtime_dependency 'newrelic_rpm', '~> 3.17'
  spec.add_runtime_dependency 'rails', '~> 5.0'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'thor', '~> 0.19'
  spec.add_development_dependency 'byebug'
end
