require 'roo_on_rails/checks/base'

module RooOnRails
  module Checks
    module Heroku
      class Login < Base
        def intro
          "Checking if you're signed in to Heroku..."
        end

        def call
          status, email = shell.run "heroku whoami"
          if status
            pass "logged in as #{bold email.strip}"
          else
            fail! "not logged in"
          end
        end

        def fix
          shell! "heroku auth:login --sso"
        end
      end
    end
  end
end

