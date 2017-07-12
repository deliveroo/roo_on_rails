require 'rack'

module RooOnRails
  module Rack
    class GoogleOauth
      OAUTH_CALLBACK = '/auth/google_oauth2/callback'.freeze

      def initialize(app, *args, &block)
        @app = app
        @args = args
        @strategy = block
      end

      def call(env)
        if is_oauth_callback?(env)
          @strategy.call(env)
        else
          send_to_upstream(env)
        end
      end

      private

      def send_to_upstream(env)
        @app.call(env)
      end

      def is_oauth_callback?(env)
        request = ::Rack::Request.new(env)
        request.fullpath.starts_with?(OAUTH_CALLBACK)
      end
    end
  end
end
