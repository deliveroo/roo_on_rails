module RooOnRails
  module Railties
    class Logging < Rails::Railtie
      initializer 'roo_on_rails.logging.before', before: :initialize_logger do
        require 'roo_on_rails/logger'
        Rails.logger = config.logger = RooOnRails::Logger.new
        # It is not possible to set log_level to an invalid value without some
        # deliberate gymnastics (the setter will raise an error), and Rails
        # defaults this to `debug`, so we don't need to guard against nil /
        # invalidity
        log_level = Rails.configuration.log_level

        Rails.logger.set_log_level(default: log_level)
        Rails.logger.debug 'initializer roo_on_rails.logging.before'
      end

      initializer 'roo_on_rails.logging.after', after: :initialize_logger do
        log_level = Rails.configuration.log_level

        Rails.logger.set_log_level(default: log_level)
        Rails.logger.debug 'initializer roo_on_rails.logging.after'
      end
    end
  end
end
