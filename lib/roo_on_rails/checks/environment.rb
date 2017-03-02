require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/github/token'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/heroku/preboot_enabled'

module RooOnRails
  module Checks
    class Environment < EnvSpecific
      requires GitHub::Token
      requires Heroku::PrebootEnabled

      def call
        # nothing to do
      end

      protected

      def intro
        "Validated #{bold @env} environment"
      end
    end
  end
end

