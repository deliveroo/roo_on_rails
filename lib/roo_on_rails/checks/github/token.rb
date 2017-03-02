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
          'Obtaining GitHub access token...'
        end

        def call
          fail! 'no token found' unless File.exist?(TOKEN_FILE)

          token = File.read(TOKEN_FILE)

          puts token
          final_fail! 'No token!' if token.nil? || token.empty?

          # status, token = shell.run 'heroku auth:token'
          # fail! 'could not get a token' unless status

          # context.heroku!.api_client = Octokit.connect_oauth(token.strip)
          # pass "connected to GitHub's API"
        end

        def fix
          token = create_access_token

          FileUtils.mkpath(File.dirname(TOKEN_FILE))
          File.write(TOKEN_FILE, token)
        rescue Octokit::Error => e
          final_fail! e.message
        end

        private

        def create_access_token
          result = client.create_authorization(
            scopes: %w(repo),
            note: token_name,
            note_url: 'https://github.com/deliveroo/roo_on_rails',
            headers: two_factor_headers
          )
          result[:token]
        rescue Octokit::UnprocessableEntity => e
          raise unless e.errors.any? { |err| err[:code] == 'already_exists' }
          final_fail! "Please delete '#{token_name}' from https://github.com/settings/tokens"
        end

        def two_factor_headers
          client.user
          {}
        rescue Octokit::OneTimePasswordRequired
          otp = ask 'Enter your GitHub 2FA code:'
          { 'X-GitHub-OTP' => otp }
        end

        def token_name
          "Roo on Rails @ #{Socket.gethostname}"
        end

        def client
          @client ||= begin
            username = ask 'Enter your GitHub username:'
            password = ask 'Enter your GitHub password (typing will be hidden):', echo: false
            say # line break after non-echoed password
            Octokit::Client.new(login: username, password: password)
          end
        end
      end
    end
  end
end
