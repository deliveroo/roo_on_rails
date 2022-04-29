module RooOnRails
  module Railties
    class Database < Rails::Railtie
      initializer 'roo_on_rails.database', after: 'active_record.initialize_database' do
        ActiveSupport.on_load :active_record do
          statement_timeout = ENV.fetch('DATABASE_STATEMENT_TIMEOUT', nil)
          reaping_frequency = ENV.fetch('DATABASE_REAPING_FREQUENCY', nil)

          if Rails.version.to_f >= 6.1
            # The config is frozen in 6.1 and will error. In 7.x the config
            # is changed from a Hash to HashConfig which has no setter
            # methods. Rails intend you to not modify the config outside of
            # the environment/*.yml files.
            Rails.logger.warn('[roo_on_rails.database] DATABASE_STATEMENT_TIMEOUT is not set') unless statement_timeout
          else
            Rails.logger.debug('[roo_on_rails.database] loading')

            config = ActiveRecord::Base.configurations[Rails.env]
            config['variables'] ||= {}

            # Use -1 to disable setting the statement timeout
            unless statement_timeout == '-1'
              config['variables']['statement_timeout'] = statement_timeout || 200
            end

            config['reaping_frequency'] = reaping_frequency if reaping_frequency
          end

          ActiveRecord::Base.establish_connection
        end
      end
    end
  end
end
