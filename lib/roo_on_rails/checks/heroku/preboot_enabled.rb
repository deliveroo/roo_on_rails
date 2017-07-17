require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/git/origin'
require 'roo_on_rails/checks/heroku/app_exists'

module RooOnRails
  module Checks
    module Heroku
      # Input context
      # - heroku.api_client: a connected PlatformAPI client
      # - heroku.app.{env}: an existing app name.
      class PrebootEnabled < EnvSpecific
        requires Git::Origin, Heroku::AppExists

        def intro
          "Checking preboot status on #{bold app_name}"
        end

        def call
          status = client.app_feature.info(app_name, 'preboot')
          if status['enabled']
            pass 'preboot enabled'
          else
            fail! 'preboot disabled'
          end
        end

        private

        def fix
          client.app_feature.update(app_name, 'preboot', enabled: true)
        end

        def app_name
          context.heroku.app[env]
        end

        def client
          context.heroku.api_client
        end
      end
    end
  end
end
