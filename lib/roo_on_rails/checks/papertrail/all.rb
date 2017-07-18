require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/papertrail/system_named'

module RooOnRails
  module Checks
    module Papertrail
      # Wrapper for Papertrail setup checks.
      class All < EnvSpecific
        requires SystemNamed

        def intro
          "Checking for Papertrail setup in #{bold env}..."
        end

        def call
          pass 'all Papertrail checks passed'
        end
      end
    end
  end
end
