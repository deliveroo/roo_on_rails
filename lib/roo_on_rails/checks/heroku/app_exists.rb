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
        
        def _intro
          "Checking if #{bold @_env} app exist..."
        end

        def _call
          all_apps = _client.app.list.map { |a| a['name'] }
          including_name = all_apps.select { |a| a.include?(_state.git_repo) }
          if including_name.empty?
            _fail "no apps with names including #{bold _state.git_repo} were detected"
          end

          correct_app = all_apps.select { |a| a =~ /^(roo-)?#{_state.git_repo}-#{@_env}$/ }

          unless correct_app.one?
            _hardfail "some apps with name #{bold _state.git_repo} exist, but I can't tell which one is for environment #{bold @_env}"
          end

          _state.heroku.app![@_env] = correct_app.first
          _ok "found app #{bold correct_app.first}"
        end

        private

        def _client
          _state.heroku.api_client
        end
      end
    end
  end
end
