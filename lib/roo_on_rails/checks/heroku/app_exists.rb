require 'roo_on_rails/checks/env_specific'
require 'roo_on_rails/checks/git/origin'
require 'roo_on_rails/checks/heroku/token'
require 'active_support/core_ext/enumerable'

module RooOnRails
  module Checks
    module Heroku
      # Check if a corresponding app exists on Heroku (for a given environment)
      #
      # Input context
      # - git_repo: the name of the repository
      # - heroku.api_client: a connected PlatformAPI client
      # - app_name_stem (optional): a name override
      #
      # Output context:
      # - heroku.app.{env}: an app name.
      class AppExists < EnvSpecific
        requires Git::Origin, Heroku::Token

        def intro
          "Checking if #{bold env} app exist..."
        end

        def call
          all_apps = client.app.list.map { |a| a['name'] }
          matches = all_apps.select { |a| candidates.include?(a) }

          if matches.empty?
            fail! "no apps with matching names detected"
          end

          if matches.many?
            final_fail! "multiple matching apps detected: #{candidates.map { |c| bold c}.join(', ')}"
          end

          context.heroku.app![env] = matches.first
          pass "found app #{bold matches.first}"
        end

        private

        def name_stem
          app_name = context.app_name_stem || context.git_repo.delete('.')
          split_app_name = app_name.split('-')
          split_app_name.combination(split_app_name.length - 1).map do |permutation|
            permutation.join('-')
          end
        end

        def candidates
          [
            ['deliveroo', 'roo', nil],
            name_stem,
            [env],
          ].tap { |a|
            a.replace a.first.product(*a[1..-1])
          }.map { |c|
            c.compact.join('-')
          }
        end

        def client
          context.heroku.api_client
        end
      end
    end
  end
end
