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
          final_fail! 'Sidekiq settings file found.' if File.exist?('config/sidekiq.yml')
        end
      end
    end
  end
end
