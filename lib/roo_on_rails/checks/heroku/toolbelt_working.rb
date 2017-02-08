require 'roo_on_rails/checks/base'

module RooOnRails
  module Checks
    module Heroku
      class ToolbeltWorking < Base
        def _intro
          "Checking if the Heroku Toolbelt is working..."
        end

        def _call
          if _run? 'heroku status > /dev/null'
            _ok 'read heroku status'
          else
            _fail "could not run 'heroku status'"
          end
        end
      end
    end
  end
end
