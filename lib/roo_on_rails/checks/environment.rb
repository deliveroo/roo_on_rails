require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/github/branch_protection'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/heroku/preboot_enabled'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/sidekiq/settings'
require 'roo_on_rails/checks/heroku/drains_metrics'
require 'roo_on_rails/checks/documentation/playbook'
require 'roo_on_rails/checks/papertrail/all'

module RooOnRails
  module Checks
    class Environment < EnvSpecific
      requires GitHub::BranchProtection
      requires Heroku::DrainsMetrics
      requires Heroku::PrebootEnabled
      requires Sidekiq::Settings
      requires Documentation::Playbook
      requires Papertrail::All

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
