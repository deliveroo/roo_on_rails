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
          @_env = env
        end
        
        def intro
          "Checking preboot status on #{bold _app}"
        end

        def call
          status = _client.app_feature.info(_app, 'preboot')
          if status['enabled']
            pass 'preboot enabled'
          else
            fail! 'preboot disabled'
          end
        end

        private

        def fix
          _client.app_feature.update(_app, 'preboot', enabled: true)
        end

        def _app
          context.heroku.app[@_env]
        end

        def _client
          context.heroku.api_client
        end
      end
    end
  end
end
