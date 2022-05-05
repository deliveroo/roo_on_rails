module RooOnRails
  module Railties
    class Database < Rails::Railtie
      initializer 'roo_on_rails.database', after: 'active_record.initialize_database' do
        ActiveSupport.on_load :active_record do
          Rails.logger.debug('[roo_on_rails.database] loading')

          if Rails::VERSION::MAJOR >= 6
            configs = ActiveRecord::Base.configurations.configurations
            db_names = configs.select { |c| c.env_name == Rails.env }.map { |c| c.name }
            db_names.each do |db_name|
              old_url_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: db_name)
              next unless old_url_config

              new_config_hash = old_url_config.configuration_hash.deep_dup
              new_config_hash[:variables] ||= {}
              statement_timeout = ENV.fetch('DATABASE_STATEMENT_TIMEOUT', 200)
              # Use -1 to disable setting the statement timeout
              new_config_hash[:variables][:statement_timeout] = statement_timeout unless statement_timeout == '-1'
              new_config_hash[:reaping_frequency] = ENV['DATABASE_REAPING_FREQUENCY'] if ENV.key?('DATABASE_REAPING_FREQUENCY')
              if old_url_config.respond_to?(:url)
                new_url_config = ActiveRecord::DatabaseConfigurations::UrlConfig.new(
                  old_url_config.env_name,
                  old_url_config.name,
                  old_url_config.url,
                  new_config_hash
                )
              else
                new_url_config = ActiveRecord::DatabaseConfigurations::HashConfig.new(
                  old_url_config.env_name,
                  old_url_config.name,
                  new_config_hash
                )
              end
              configs.delete(old_url_config)
              configs << new_url_config
            end
          else
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
          end

          ActiveRecord::Base.establish_connection
        end
      end
    end
  end
end
