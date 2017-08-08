require 'roo_on_rails/version'

module RooOnRails
end

if defined?(Rails)
  require 'dotenv/rails-now'
  require 'roo_on_rails/railtie'
  require 'roo_on_rails/railties/new_relic'
  require 'roo_on_rails/railties/database'
  require 'roo_on_rails/railties/http'
  require 'roo_on_rails/railties/sidekiq'
  require 'roo_on_rails/railties/rake_tasks'
  require 'roo_on_rails/railties/google_oauth'
  require 'roo_on_rails/railties/routemaster'
end
