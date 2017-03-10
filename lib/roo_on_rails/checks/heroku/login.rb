require 'roo_on_rails/checks/base'
require 'roo_on_rails/checks/heroku/toolbelt_working'

module RooOnRails
  module Checks
    module Heroku
      class Login < Base
        requires ToolbeltWorking

        def intro
          "Checking if you're signed in to Heroku..."
        end

        def call
          status, email = shell.run 'heroku whoami'
          if status
            pass "logged in as #{bold email.strip}"
          else
            fail! 'not logged in'
          end
        end

        def fix
          shell.run! 'heroku auth:login --sso'
        end
      end
    end
  end
end
