# inspiration from:
# https://devcenter.heroku.com/articles/concurrency-and-database-connections#multi-process-servers
# https://devcenter.heroku.com/articles/postgres-logs-errors#pgerror-prepared-statement-a30-already-exists
# http://stackoverflow.com/questions/8118074/is-the-prepared-statement-cache-cleared-per-request-in-rails-3-1
# http://stackoverflow.com/questions/16775795/rails-switch-connection-on-each-request-but-keep-a-connection-pool

module RooOnRails
  module Rack
    # Cleans up Rails database connections on timeouts, before they're returned
    # to the pool.
    #
    # In particular, this clears the prepared statement cache, which can become
    # corrupted as ActiveRecord isn't interrupt-safe.
    class SafeTimeouts
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      rescue Rack::Timeout::Error, Rack::Timeout::RequestTimeoutException
        Rails.logger.warn('Clearing ActiveRecord connection cache due to timeout')
        ActiveRecord::Base.connection.clear_cache!
        raise
      end
    end
  end
end
