require 'roo_on_rails/checks/base'

module RooOnRails
  module Checks
    module Heroku
      class Login < Base
        def _intro
          "Checking if you're signed in to Heroku..."
        end

        def _call
          status, email = _run "heroku whoami"
          if status
            _ok "logged in as #{bold email.strip}"
          else
            _fail "not logged in"
          end
        end

        def _fix
          _run! "heroku auth:login --sso"
        end
      end
    end
  end
end

