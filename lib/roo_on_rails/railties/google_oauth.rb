require 'roo_on_rails/config'

module RooOnRails
  module Railties
    class GoogleOAuth < Rails::Railtie
      initializer 'roo_on_rails.google_auth.middleware' do |app|
        next unless Config.google_auth_enabled?
        Rails.logger.debug '[roo_on_rails.google_auth] loading'
        _add_middleware(app)
        _add_routes(app)
      end

      private

      def _add_middleware(app)
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
        prefix = Config.google_auth_path_prefix
        ctrl   = Config.google_auth_controller

        app.routes.prepend do
          get  "#{prefix}/google_oauth2",           controller: ctrl, action: 'failure'
          get  "#{prefix}/google_oauth2/callback",  controller: ctrl, action: 'create'
          post "#{prefix}/google_oauth2/callback",  controller: ctrl, action: 'create'
          get  "#{prefix}/failure",                 controller: ctrl, action: 'failure'
          get  "#{prefix}/logout",                  controller: ctrl, action: 'destroy'
        end
      end
    end
  end
end
