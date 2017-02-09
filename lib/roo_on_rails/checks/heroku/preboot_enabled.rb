require 'roo_on_rails/checks/base'
require 'roo_on_rails/checks/multi'

module RooOnRails
  module Checks
    module Heroku
      # Input context
      # - heroku.api_client: a connected PlatformAPI client
      # - heroku.app.{env}: an existing app name.
      class PrebootEnabled < Base
        All = Multi.new(variants: %w[staging production], of: self)

        def initialize(env, **options)
          super(options)
          @env = env
        end
        
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
          context.heroku.app[@env]
        end

        def client
          context.heroku.api_client
        end
      end
    end
  end
end
