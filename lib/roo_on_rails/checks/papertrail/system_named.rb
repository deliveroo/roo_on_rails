require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/papertrail/token'
require 'roo_on_rails/checks/papertrail/system_exists'

module RooOnRails
  module Checks
    module Papertrail
      # Checks that the Papertrail system for an app in named like the app
      #
      # Input context
      # - heroku.app.{env}
      # - papertrail.system_id.{env}: a Papertrail system ID
      # - papertrail.client
      #
      # Output context:
      # - None
      class SystemNamed < EnvSpecific
        requires Heroku::AppExists
        requires Token
        requires SystemExists

        def intro
          'Checking that the app is named in Papertrail'
        end

        def call
          data = context.papertrail.client.get_system(system_id)

          fail! "wrong name for Papertrail system '#{system_id}' found" if data.name != app_name

          pass "system #{system_id} named #{app_name}"
        end

        def fix
          context.papertrail.client.update_system(name: app_name)
        end

        private

        def system_id
          context.papertrail.system_id[env]
        end

        def app_name
          context.heroku.app[env]
        end

        def heroku
          context.heroku.api_client
        end
      end
    end
  end
end
