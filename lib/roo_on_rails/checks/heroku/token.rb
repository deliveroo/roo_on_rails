require 'roo_on_rails/checks/base'
require 'platform-api'

module RooOnRails
  module Checks
    module Heroku
      # Output context:
      # - heroku.api_client: a connected PlatformAPI client
      class Token < Base
        def intro
          "Obtaining Heroku auth token..."
        end

        def call
          status, token = shell "heroku auth:token"
          fail! "could not get a token" unless status

          context.heroku!.api_client = PlatformAPI.connect_oauth(token.strip)
          pass "connected to Heroku's API"
        end
      end
    end
  end
end
