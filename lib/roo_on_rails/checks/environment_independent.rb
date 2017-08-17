require 'roo_on_rails/checks/base'
require 'roo_on_rails/checks/github/branch_protection'
require 'roo_on_rails/checks/sidekiq/settings'
require 'roo_on_rails/checks/documentation/playbook'

module RooOnRails
  module Checks
    class EnvironmentIndependent < Base
      requires GitHub::BranchProtection
      requires Documentation::Playbook
      requires Sidekiq::Settings

      def intro
        "Validating environment-independent setup"
      end

      def call
        say "All good", :green
      end

      protected

    end
  end
end
