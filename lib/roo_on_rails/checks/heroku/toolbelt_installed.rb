require 'roo_on_rails/checks/base'

module RooOnRails
  module Checks
    module Heroku
      class ToolbeltInstalled < Base
        def intro
          "Checking if the Heroku Toolbelt is installed..."
        end

        def call
          status, path = shell "which heroku"
          if status
            pass "found #{bold path.strip} binary"
          else
            fail! "'heroku' binary missing"
          end
        end
      end
    end
  end
end

