module RooOnRails
  module Railties
    class Logging < Rails::Railtie
      initializer 'roo_on_rails.logging.before', before: :initialize_logger do
        require 'roo_on_rails/logger'
        Rails.logger = config.logger = RooOnRails::Logger.new
        Rails.logger.debug 'initializer roo_on_rails.logging.before'
      end

      initializer 'roo_on_rails.logging.after', after: :initialize_logger do
        Rails.logger.set_log_level
        Rails.logger.debug 'initializer roo_on_rails.logging.after'
      end
    end
  end
end
