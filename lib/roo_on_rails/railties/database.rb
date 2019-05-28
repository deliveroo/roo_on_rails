module RooOnRails
  module Railties
    class Database < Rails::Railtie
      initializer 'roo_on_rails.database', after: 'active_record.initialize_database' do
        ActiveSupport.on_load :active_record do
          Rails.logger.with(initializer: 'roo_on_rails.database') do |log|
            log.debug 'loading'

            config = ActiveRecord::Base.configurations[Rails.env]
            config['variables'] ||= {}
            statement_timeout = ENV.fetch('DATABASE_STATEMENT_TIMEOUT', 200)
            # Use -1 to disable setting the statement timeout
            unless statement_timeout == '-1'
              config['variables']['statement_timeout'] = statement_timeout
            end
            if ENV.key?('DATABASE_REAPING_FREQUENCY')
              config['reaping_frequency'] = ENV['DATABASE_REAPING_FREQUENCY']
            end
            ActiveRecord::Base.establish_connection
          end
        end
      end
    end
  end
end
