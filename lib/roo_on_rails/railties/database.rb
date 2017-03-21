module RooOnRails
  module Railties
    class Database < Rails::Railtie
      initializer 'roo_on_rails.database', after: 'active_record.initialize_database' do |_app|
        $stderr.puts 'initializer roo_on_rails.database'

        ActiveRecord::Base.configurations[Rails.env]['timeout'] = ENV.fetch('DATABASE_TIMEOUT', 200)
        ActiveRecord::Base.establish_connection
      end
    end
  end
end
