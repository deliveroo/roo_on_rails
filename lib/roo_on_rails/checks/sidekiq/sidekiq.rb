require 'roo_on_rails/checks/base'

module RooOnRails
  module Checks
    module Sidekiq
      class Sidekiq < Base
        WORKER_PROCFILE_LINE = 'worker: bundle exec roo_on_rails sidekiq'.freeze

        def intro
          'Checking Sidekiq Setup...'
        end

        def call
          unless ENV.fetch('SIDEKIQ_ENABLED', 'true').to_s =~ /\A(YES|TRUE|ON|1)\Z/i
            pass 'SIDEKIQ_ENABLED is set to false'
            return
          end
          check_for_procfile
          pass 'found valid Procfile'
        end

        def fix
          output = File.exist?('Procfile') ? "\n#{WORKER_PROCFILE_LINE}" : WORKER_PROCFILE_LINE
          File.open('Procfile', 'a') { |f| f.write(output) }
        end

        def check_for_procfile
          return if File.exist?('Procfile') && File.read('Procfile').include?('worker')
          fail! "No Procfile found with a 'worker' command"
        end
      end
    end
  end
end
