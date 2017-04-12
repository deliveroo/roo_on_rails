require 'roo_on_rails/environment'
module RooOnRails
  module Sidekiq
    class Loader
      def self.run
        RooOnRails::Environment.load
        ENV['RAILS_MAX_THREADS'] = (ENV.fetch('SIDEKIQ_THREADS').to_i + 1).to_s
        ENV['DATABASE_REAPING_FREQUENCY'] = ENV['SIDEKIQ_DATABASE_REAPING_FREQUENCY']
        exec 'sidekiq'
      end
    end
  end
end
