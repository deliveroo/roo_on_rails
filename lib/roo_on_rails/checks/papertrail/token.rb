require 'roo_on_rails/checks/base'
require 'roo_on_rails/checks/git/origin'
require 'roo_on_rails/papertrail_client'
require 'io/console'
require 'shellwords'

module RooOnRails
  module Checks
    module Papertrail
      # Output context:
      # - papertrail.client: a connected Papertrail client
      class Token < Base
        requires Git::Origin

        def intro
          'Obtaining Papertrail auth token...'
        end

        def call
          token = `git config papertrail.token`.strip
          fail! 'no Papertrail API token configured' if token.empty?

          client = PapertrailClient.new(token: token)
          begin
            client.list_destinations
          rescue Faraday::ClientError => e
            fail! "connecting to Papertrail failed (#{e.message})"
          end

          pass "connected to Papertrail's API"
          context.papertrail!.client = client
        end

        def fix
          say 'Enter your Papertrail API token:'
          say 'This can be found at https://papertrailapp.com/account/profile'
          say '(the token will not be echoed on the terminal; paste and press enter)'
          token = IO.console.getpass.strip
          system "git config papertrail.token #{Shellwords.shellescape token}"
        end
      end
    end
  end
end
