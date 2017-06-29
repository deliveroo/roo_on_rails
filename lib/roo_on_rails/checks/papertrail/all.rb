require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/papertrail/drain_exists'
require 'roo_on_rails/checks/papertrail/system_in_group'

module RooOnRails
  module Checks
    module Papertrail
      # Wrapper for Papertrail setup checks.
      class All < EnvSpecific
        requires DrainExists
        requires SystemInGroup

        def intro
          "Checking for Papertrail setup in #{bold env}..."
        end
      end
    end
  end
end
