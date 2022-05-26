if defined?(ActiveRecord)
  namespace :db do
    desc 'Prints out the database statement timeout'
    task statement_timeout: :environment do
      result = ActiveRecord::Base.connection.execute('SHOW statement_timeout').first
      puts result['statement_timeout']
    end
  end

  %i(
    db:create
    db:drop
    db:migrate
    db:migrate:down
    db:rollback
  ).each do |task|
    Rake::Task[task]
  end
end
