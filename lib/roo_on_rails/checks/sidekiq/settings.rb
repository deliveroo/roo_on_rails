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
          fail! 'No sidekiq settings found' unless File.exist?('config/sidekiq.yml')
          return if File.read('config/sidekiq.yml') == yaml_template
          final_fail! 'Custom sidekiq settings found.'
        end

        def fix
          create_file 'config/sidekiq.yml', yaml_template
        end

        def yaml_template
          '<%= RooOnRails::Sidekiq::Settings.settings_template %>'
        end
      end
    end
  end
end
