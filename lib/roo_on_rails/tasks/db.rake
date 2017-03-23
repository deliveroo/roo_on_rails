namespace :db do
  desc 'Prints out the database statement timeout'
  task statement_timeout: :environment do
    result = ActiveRecord::Base.connection.execute('SHOW statement_timeout').first
    puts result['statement_timeout']
  end
end
