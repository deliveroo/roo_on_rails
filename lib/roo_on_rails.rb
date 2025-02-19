require 'roo_on_rails/version'

module RooOnRails
end

if defined?(Rails)
  require 'dotenv/rails-now'
  require 'roo_on_rails/railties/env'
  require 'roo_on_rails/railties/http'
  require 'roo_on_rails/railties/sidekiq_integration'
  require 'roo_on_rails/railties/rake_tasks'
  require 'roo_on_rails/railties/google_oauth'
  require 'roo_on_rails/railties/roo_identity'
end
