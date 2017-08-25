require 'roo_on_rails/logger'

module RooOnRails
  module Railties
    class Logging < Rails::Railtie
      initializer 'roo_on_rails.logging', before: :initialize_logger do
        $stderr.puts 'initializer roo_on_rails.logging'

        ::Rails.logger = config.logger = RooOnRails::Logger.new
      end
    end
  end
end
