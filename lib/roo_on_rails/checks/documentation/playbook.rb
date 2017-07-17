require 'roo_on_rails/checks/base'

module RooOnRails
  module Checks
    module Documentation
      class Playbook < Base
        LOCATION = 'PLAYBOOK.md'.freeze

        def intro
          'Looking for an on-call Playbook...'
        end

        def call
          if File.exist?(LOCATION)
            pass 'playbook found, legion on-call engineers thank you.'
          else
            fail! "please create a playbook at #{LOCATION}."
          end
        end
      end
    end
  end
end
