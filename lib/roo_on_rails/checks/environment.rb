require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/heroku/preboot_enabled'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/heroku/drains_metrics'
require 'roo_on_rails/checks/papertrail/all'

module RooOnRails
  module Checks
    class Environment < EnvSpecific
      requires Heroku::DrainsMetrics
      requires Heroku::PrebootEnabled
      requires Papertrail::All

      def call
        pass 'all good'
      end

      protected

      def intro
        "Validating #{bold @env} environment"
      end
    end
  end
end
