require 'roo_on_rails/config'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'active_support/core_ext/object/blank'

module RooOnRails
  module Railties
    class GoogleAuth < Rails::Railtie
      initializer 'roo_on_rails.google_auth' do |app|
        if RooOnRails::Config.google_auth_enabled?
          $stderr.puts 'initializer roo_on_rails.google_auth'

          google_oauth2_client_id = ENV.fetch("GOOGLE_AUTH_CLIENT_ID")
          google_oauth2_client_secret = ENV.fetch("GOOGLE_AUTH_CLIENT_SECRET")

          options = {
            path_prefix: '/auth',
            prompt: 'consent',
          }

          domain_list = ENV.fetch("GOOGLE_AUTH_ALLOWED_DOMAINS", "").split(",").reject(&:blank?)
          options[:hd] = domain_list if domain_list.any?

          app.config.middleware.use ::OmniAuth::Builder do
            provider :google_oauth2,
              google_oauth2_client_id,
              google_oauth2_client_secret,
              options
          end
        else
          $stderr.puts 'skipping initializer roo_on_rails.google_auth'
        end
      end
    end
  end
end
