module RooOnRails
  module Railties
    class Database < Rails::Railtie
      if ActiveRecord::VERSION::MAJOR >= 4
        initializer 'roo_on_rails.database', after: 'active_record.initialize_database' do
          $stderr.puts 'initializer roo_on_rails.database'

          config = ActiveRecord::Base.configurations[Rails.env]
          config['variables'] ||= {}
          config['variables']['statement_timeout'] = ENV.fetch('DATABASE_STATEMENT_TIMEOUT', 200)
          config['reaping_frequency'] = ENV['DATABASE_REAPING_FREQUENCY']

          ActiveRecord::Base.establish_connection
        end
      end
    end
  end
end
