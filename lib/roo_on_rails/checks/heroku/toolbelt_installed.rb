require 'roo_on_rails/checks/base'

module RooOnRails
  module Checks
    module Heroku
      class ToolbeltInstalled < Base
        def _intro
          "Checking if the Heroku Toolbelt is installed..."
        end

        def _call
          status, path = _run "which heroku"
          if status
            _ok "found #{bold path.strip} binary"
          else
            _fail "'heroku' binary missing"
          end
        end
      end
    end
  end
end

