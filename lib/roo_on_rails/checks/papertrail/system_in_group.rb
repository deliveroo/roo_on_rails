require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/papertrail/system_exists'
require 'roo_on_rails/checks/papertrail/token'

module RooOnRails
  module Checks
    module Papertrail
      # Check if an app's Papertrail logs are grouped with other apps in the
      # same environment.
      #
      # Input context
      # - heroku.papertrail.client: a connected Papertrail client
      #
      # Output context:
      # - FIXME
      class SystemInGroup < EnvSpecific
        requires SystemExists
        requires Token
      end
    end
  end
end

