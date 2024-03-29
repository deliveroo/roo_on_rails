if defined?(ActiveRecord)
  namespace :db do
    desc 'Prints out the database statement timeout'
    task statement_timeout: :environment do
      ActiveRecord::Base.establish_connection
      result = ActiveRecord::Base.connection.execute('SHOW statement_timeout').first
      puts result['statement_timeout']
    end

    namespace :migrate do
      task extend_statement_timeout: :environment do
        rails_version = Gem::Version.new(Rails.version)

        if rails_version < Gem::Version.new('6.1')
          config = ActiveRecord::Base.configurations[Rails.env]
          config['variables'] ||= {}
          config['variables']['statement_timeout'] = ENV.fetch('MIGRATION_STATEMENT_TIMEOUT', 10_000)
        else
          configs = ActiveRecord::Base.configurations.configurations
          old_url_config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: 'primary')
          new_config_hash = old_url_config.configuration_hash.deep_dup
          new_config_hash[:variables] ||= {}
          new_config_hash[:variables][:statement_timeout] = ENV.fetch('MIGRATION_STATEMENT_TIMEOUT', 10_000)
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
      end
    end
  end

  %i(
    db:create
    db:drop
    db:migrate
    db:migrate:down
    db:rollback
  ).each do |task|
    Rake::Task[task].enhance(%i[db:migrate:extend_statement_timeout])
  end
end
