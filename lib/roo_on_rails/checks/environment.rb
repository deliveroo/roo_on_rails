require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/heroku/preboot_enabled'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/heroku/drains_metrics'

module RooOnRails
  module Checks
    class Environment < EnvSpecific
      requires Heroku::DrainsMetrics
      requires Heroku::PrebootEnabled

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
