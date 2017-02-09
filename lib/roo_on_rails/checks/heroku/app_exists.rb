require 'roo_on_rails/checks/base'
require 'roo_on_rails/checks/multi'
require 'active_support/core_ext/enumerable'

module RooOnRails
  module Checks
    module Heroku
      # Check if a corresponding app exists on Heroku (for a given environment)
      # 
      # Input context
      # - heroku.api_client: a connected PlatformAPI client
      # - app_name_stem (optional): a name override
      #
      # Output context:
      # - heroku.app.{env}: an app name.
      class AppExists < Base
        All = Multi.new(variants: %w[staging production], of: self)

        def initialize(env, **options)
          super(options)
          @env = env
        end
        
        def intro
          "Checking if #{bold @env} app exist..."
        end

        def call
          all_apps = client.app.list.map { |a| a['name'] }
          matches = all_apps.select { |a| candidates.include?(a) }

          unless matches.one?
            say "\tcandidates: #{candidates.join(', ')}"
          end

          if matches.empty?
            fail! "no apps with matching names detected"
          end

          if matches.many?
            fail‼︎ "multiple matching apps detected: #{candidates.map { |c| bold c}.join(', ')}"
          end

          context.heroku.app![@env] = matches.first
          pass "found app #{bold matches.first}"
        end

        private

        def name_stem
          context.app_name_stem || context.git_repo.gsub('.', '')
        end

        def candidates
          [
            [nil, 'roo', 'deliveroo'],
            [name_stem],
            [@env],
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
