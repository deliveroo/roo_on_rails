require 'roo_on_rails/checks/base'
require 'roo_on_rails/checks/multi'

module RooOnRails
  module Checks
    module Heroku
      class PrebootEnabled < Base
        All = Multi.new(variants: %w[staging production], of: self)

        def initialize(env, **options)
          super(options)
          @_env = env
        end
        
        def _intro
          "Checking preboot status on #{bold _app}"
        end

        def _call
          status = _client.app_feature.info(_app, 'preboot')
          if status['enabled']
            _ok 'preboot enabled'
          else
            _fail 'preboot disabled'
          end
        end

        private

        def _fix
          _client.app_feature.update(_app, 'preboot', enabled: true)
        end

        def _app
          _state.heroku.app[@_env]
        end

        def _client
          _state.heroku.api_client
        end
      end
    end
  end
end
