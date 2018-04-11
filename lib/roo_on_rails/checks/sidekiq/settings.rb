require 'roo_on_rails/checks/base'
require 'thor'

module RooOnRails
  module Checks
    module Sidekiq
      class Settings < Base
        def intro
          'Checking Sidekiq settings.yml...'
        end

        def call
          if File.exist?('config/sidekiq.yml')
            message = [
              'Custom Sidekiq settings found.',
              'Please see the Roo On Rails readme for more information.'
            ].join("\n")

            fail! message
          end
        end
      end
    end
  end
end
