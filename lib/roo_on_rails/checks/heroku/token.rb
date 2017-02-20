require 'roo_on_rails/checks/base'
require 'roo_on_rails/checks/heroku/login'
require 'platform-api'

module RooOnRails
  module Checks
    module Heroku
      # Output context:
      # - heroku.api_client: a connected PlatformAPI client
      class Token < Base
        requires Login

        def intro
          "Obtaining Heroku auth token..."
        end

        def call
          status, token = shell.run "heroku auth:token"
          fail! "could not get a token" unless status

          context.heroku!.api_client = PlatformAPI.connect_oauth(token.strip)
          pass "connected to Heroku's API"
        end
      end
    end
  end
end
