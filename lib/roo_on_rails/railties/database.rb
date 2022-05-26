module RooOnRails
  module Railties
    class Database < Rails::Railtie
      initializer 'roo_on_rails.database', after: 'active_record.initialize_database' do
        ActiveSupport.on_load :active_record do
          Rails.logger.debug('[roo_on_rails.database] loading')

          ActiveRecord::Base.configurations.configurations.each do |config|
            next unless config.env_name == Rails.env

            next if config.configuration_hash[:variables]&.[]('statement_timeout')

            message = <<-TEXT
RooOnRails no longer manages DATABASE_STATEMENT_TIMEOUT.
Please set this yourself inside of config/database.yml

Example:

default: &default
  adapter: postgres
  port: 5432
  ...
  variables:
    statement_timeout: <%= ENV['DATABASE_STATEMENT_TIMEOUT'] || 200 %>
            TEXT

            Rails.logger.error(message)
            raise StandardError, 'DATABASE_STATEMENT_TIMEOUT not set'
          end

          ActiveRecord::Base.establish_connection
        end
      end
    end
  end
end
