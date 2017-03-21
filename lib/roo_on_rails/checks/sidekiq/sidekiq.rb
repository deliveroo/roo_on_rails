require 'roo_on_rails/checks/base'
require 'thor'

module RooOnRails
  module Checks
    module Sidekiq
      class Sidekiq < Base
        WORKER_PROCFILE_LINE='worker: RAILS_MAX_THREADS=$SIDEKIQ_DB_POOL_SIZE DB_REAPING_FREQUENCY=$SIDEKIQ_DB_REAPING_FREQUENCY bundle exec sidekiq'

        def intro
          "Checking Sidekiq Setup..."
        end

        def call
          unless ENV.fetch('SIDEKIQ_ENBALED', 'true').to_s =~ /\A(YES|TRUE|ON|1)\Z/i
            pass 'SIDEKIQ_ENBALED is set to false'
            return
          end
          check_for_sidekiq
          check_for_procfile
        end

        def check_for_sidekiq
          _, gems = shell.run 'bundle list | grep sidekiq'
          unless gems.include?('sidekiq')
            fail! "Sidekiq is not installed, see the README: https://github.com/deliveroo/roo_on_rails#sidekiq"
          end
        end

        def check_for_procfile
          return if File.exists?('Procfile') && File.read('Procfile').include?('worker')
          say "No Procfile with workers entry found. Adding one"
          if File.exists?('Procfile')
            raise 'appending'
            append_to_file 'Procfile', "\n#{WORKER_PROCFILE_LINE}"
          else
            create_file 'Procfile', WORKER_PROCFILE_LINE
          end
        end
      end
    end
  end
end
