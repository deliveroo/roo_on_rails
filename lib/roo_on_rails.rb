require 'roo_on_rails/version'
require 'dotenv/rails-now'

module RooOnRails
end

require 'roo_on_rails/railtie' if defined?(Rails)
