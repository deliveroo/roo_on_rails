require 'roo_on_rails/checks/base'
require 'roo_on_rails/checks/multi'

module RooOnRails
  module Checks
    module Heroku
      class AppExists < Base
        All = Multi.new(variants: %w[staging production], of: self)

        def initialize(env, **options)
          super(options)
          @_env = env
        end
        
        def intro
          "Checking if #{bold @_env} app exist..."
        end

        def call
          all_apps = _client.app.list.map { |a| a['name'] }
          including_name = all_apps.select { |a| a.include?(context.git_repo) }
          if including_name.empty?
            fail! "no apps with names including #{bold context.git_repo} were detected"
          end

          correct_app = all_apps.select { |a| a =~ /^(roo-)?#{context.git_repo}-#{@_env}$/ }

          unless correct_app.one?
            fail‼ "some apps with name #{bold context.git_repo} exist, but I can't tell which one is for environment #{bold @_env}"
          end

          context.heroku.app![@_env] = correct_app.first
          pass "found app #{bold correct_app.first}"
        end

        private

        def _client
          context.heroku.api_client
        end
      end
    end
  end
end
