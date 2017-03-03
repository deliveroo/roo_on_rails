require 'roo_on_rails/checks/base'
require 'octokit'
require 'socket'

module RooOnRails
  module Checks
    module GitHub
      # Output context:
      # - github.api_client: a connected Octokit client
      class Token < Base
        TOKEN_FILE = File.expand_path('~/.roo_on_rails/github-token').freeze
        private_constant :TOKEN_FILE

        def intro
          'Obtaining GitHub auth token...'
        end

        def call
          token = File.exist?(TOKEN_FILE) && File.read(TOKEN_FILE)
          fail! 'no token found' unless token && !token.empty?

          oauth_client = Octokit::Client.new(access_token: token)
          oauth_client.user
          context.github!.api_client = oauth_client
          pass "connected to GitHub's API"
        rescue Octokit::Error => e
          final_fail! "#{e.class}: #{e.message}"
        end

        def fix
          token = create_access_token
          FileUtils.mkpath(File.dirname(TOKEN_FILE))
          File.write(TOKEN_FILE, token)
        rescue Octokit::Error => e
          final_fail! "#{e.class}: #{e.message}"
        end

        private

        def create_access_token
          delete_existing_access_token
          result = basic_client.create_authorization(
            scopes: %w(repo),
            note: token_name,
            note_url: 'https://github.com/deliveroo/roo_on_rails',
            headers: two_factor_headers
          )
          result[:token]
        end

        def delete_existing_access_token
          authorizations = basic_client.authorizations(headers: two_factor_headers)
          authorization = authorizations.find { |a| a[:note] == token_name }
          return unless authorization

          basic_client.delete_authorization(authorization[:id], headers: two_factor_headers)
        end

        def basic_client
          @basic_client ||= begin
            username = ask 'Enter your GitHub username:'
            password = ask 'Enter your GitHub password (typing will be hidden):', echo: false
            say # line break after non-echoed password
            Octokit::Client.new(login: username, password: password)
          end
        end

        def two_factor_headers
          @two_factor_headers ||= begin
            basic_client.user # idempotent call just to check access
            {}
          rescue Octokit::OneTimePasswordRequired
            otp = ask 'Enter your GitHub 2FA code:'
            { 'X-GitHub-OTP' => otp }
          end
        end

        def token_name
          "Roo on Rails @ #{Socket.gethostname}"
        end
      end
    end
  end
end
