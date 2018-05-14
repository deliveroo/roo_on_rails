require 'roo_on_rails/version'

module RooOnRails
end

if defined?(Rails)
  require 'dotenv/rails-now'
  require 'roo_on_rails/railties/logging'
  require 'roo_on_rails/railties/env'
  require 'roo_on_rails/railties/new_relic'
  require 'roo_on_rails/railties/database'
  require 'roo_on_rails/railties/http'
  require 'roo_on_rails/railties/sidekiq_integration'
  require 'roo_on_rails/railties/rake_tasks'
  require 'roo_on_rails/railties/routemaster'
  require 'roo_on_rails/railties/roo_identity'
end
