require 'roo_on_rails/checks/env_specific'

module RooOnRails
  module Checks
    class Environment < EnvSpecific
      # Used to include the Heroku and Papertrail checks,
      # now it's empty

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
