require 'roo_on_rails/checks/base'
require 'platform-api'

module RooOnRails
  module Checks
    module Heroku
      class Token < Base
        def _intro
          "Obtaining Heroku auth token..."
        end

        def _call
          status, token = _run "heroku auth:token"
          _fail "could not get a token" unless status

          _state.heroku!.api_client = PlatformAPI.connect_oauth(token.strip)
          _ok "connected to Heroku's API"
        end
      end
    end
  end
end
