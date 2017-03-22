module RooOnRails
  module Railties
    class Database < Rails::Railtie
      initializer 'roo_on_rails.database', after: 'active_record.initialize_database' do
        $stderr.puts 'initializer roo_on_rails.database'

        config = ActiveRecord::Base.configurations[Rails.env]
        config['variables'] ||= {}
        config['variables']['statement_timeout'] = ENV.fetch('DATABASE_STATEMENT_TIMEOUT', 200)

        ActiveRecord::Base.establish_connection
      end
    end
  end
end