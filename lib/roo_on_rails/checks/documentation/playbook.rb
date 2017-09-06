require 'roo_on_rails/checks/base'
require 'fileutils'

module RooOnRails
  module Checks
    module Documentation
      class Playbook < Base
        LOCATION = 'PLAYBOOK.md'.freeze

        def intro
          'Looking for an on-call Playbook...'
        end

        def call
          fail! "no playbook at #{LOCATION}." if playbook_missing?
          final_fail! 'playbook still contains FIXME template sections' if playbook_unfinished?
          pass 'playbook found, legion on-call engineers thank you.'
        end

        def fix
          FileUtils.cp(
            File.join(__dir__, 'playbook_template.md'),
            LOCATION
          )
        end

        private

        def playbook_unfinished?
          # The regexp is so that you can still refer to strings saying FIXME in your readme
          # if you need to, by putting the phrase in backticks: `FIXME`
          !File.read(LOCATION).match(/FIXME(?!`)/).nil?
        end

        def playbook_missing?
          !File.exist?(LOCATION)
        end
      end
    end
  end
end
