require 'roo_on_rails/checks/sidekiq/sidekiq'
require 'roo_on_rails/checks/base'
require 'thor'

module RooOnRails
  module Checks
    module Sidekiq
      class Settings < Base
        requires Sidekiq
        def intro
          'Checking Sidekiq settings.yml...'
        end

        def call
          if File.exist?('config/sidekiq.yml')
            fail! <<~MSG
            Custom Sidekiq settings found.
              Please see the Roo On Rails readme for more information.
            MSG
          end
        end
      end
    end
  end
end
