require 'roo_on_rails/version'

module RooOnRails
end

if defined?(Rails)
  require 'dotenv/rails-now'
  require 'roo_on_rails/railtie'
end
