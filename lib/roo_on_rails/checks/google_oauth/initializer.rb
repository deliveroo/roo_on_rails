require 'roo_on_rails/config'
require 'roo_on_rails/checks/base'
require 'fileutils'

module RooOnRails
  module Checks
    module GoogleOauth
      class Initializer < Base

        LOCATION = "config/initializers/google_oauth.rb".freeze

        def call
          if RooOnRails::Config.google_auth_enabled?
            check_initializer
          else
            pass "Google Oauth is not enabled. Doing nothing"
          end
        end

        def fix
          FileUtils.cp(template, LOCATION)
        end

        private

        def check_initializer
          if File.exists? LOCATION
            pass "Google Oauth initializer is present. Doing nothing."
          else
            fail! "Google Oauth is enabled but the initializer is missing."
          end
        end

        def template
          File.join(__dir__, "_template.rb")
        end
      end
    end
  end
end
