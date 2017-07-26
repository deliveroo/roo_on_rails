module RooOnRails
  module Railties
    class GoogleOAuth < Rails::Railtie
      initializer 'roo_on_rails.google_auth.middleware' do |app|
        _if_enabled do
          _add_middleware(app)
        end
      end

      initializer 'roo_on_rails.google_auth.routes', after: :set_routes_reloader_hook do |app|
        _if_enabled do
          _add_routes(app)
          # support development mode on route changes (only works in Rails 5)
          app.reloader.to_prepare { _add_routes(app) }
        end
      end

      private

      def _if_enabled
        return unless Config.google_auth_enabled?
        if Rails::VERSION::MAJOR < 5
          Rails.logger.warn 'The Google OAuth feature is not supported with Rails < 5'
          return
        end

        yield
      end

      def _add_middleware(app)
        $stderr.puts 'initializer roo_on_rails.google_auth.middleware'

        require 'roo_on_rails/config'
        require 'omniauth'
        require 'omniauth-google-oauth2'
        require 'active_support/core_ext/object/blank'

        options = {
          path_prefix: Config.google_auth_path_prefix,
          prompt: 'consent',
          # https://stackoverflow.com/questions/45271730/jwtinvalidissuererror-invalid-issuer-expected-accounts-google-com-received
          # https://github.com/zquestz/omniauth-google-oauth2/issues/197
          skip_jwt: true,
        }

        domain_list = ENV.fetch('GOOGLE_AUTH_ALLOWED_DOMAINS', '').split(',').reject(&:blank?)
        options[:hd] = domain_list if domain_list.any?

        app.config.middleware.use ::OmniAuth::Builder do
          provider :google_oauth2,
            ENV.fetch('GOOGLE_AUTH_CLIENT_ID'),
            ENV.fetch('GOOGLE_AUTH_CLIENT_SECRET'),
            options
        end
      end

      def _add_routes(app)
        $stderr.puts 'initializer roo_on_rails.google_auth.routes'

        prefix = Config.google_auth_path_prefix
        ctrl   = Config.google_auth_controller

        app.routes.disable_clear_and_finalize = true
        app.routes.draw do
          get  "#{prefix}/google_oauth2",           controller: ctrl, action: 'failure'
          get  "#{prefix}/google_oauth2/callback",  controller: ctrl, action: 'create'
          post "#{prefix}/google_oauth2/callback",  controller: ctrl, action: 'create'
          get  "#{prefix}/failure",                 controller: ctrl, action: 'failure'
          get  "#{prefix}/logout",                  controller: ctrl, action: 'destroy'
        end
        app.routes.disable_clear_and_finalize = false
      end
    end
  end
end
