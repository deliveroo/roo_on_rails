if defined?(ActiveRecord)
  namespace :db do
    desc 'Prints out the database statement timeout'
    task statement_timeout: :environment do
      result = ActiveRecord::Base.connection.execute('SHOW statement_timeout').first
      puts result['statement_timeout']
    end

    namespace :migrate do
      task extend_statement_timeout: :environment do
        config = ActiveRecord::Base.configurations[Rails.env].dup
        config['variables'] ||= {}
        config['variables']['statement_timeout'] = ENV.fetch('MIGRATION_STATEMENT_TIMEOUT', 10_000)
        ActiveRecord::Base.establish_connection(config)
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
