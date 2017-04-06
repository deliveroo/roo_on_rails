require 'spec_helper'
require 'spec/support/run_test_app'
require 'active_record'

describe 'Database setup', rails_min_version: 4 do
  run_test_app
  let(:app_options) {{ database: 'postgresql' }}

  before { app.wait_start }

  context 'When booting' do
    before { app_helper.shell_run "cd #{app_path} && rake db:create" }
    after  { app_helper.shell_run "cd #{app_path} && rake db:drop" }

    let(:statement_timeout) { app_helper.shell_run "cd #{app_path} && rake db:statement_timeout" }

    context 'when DATABASE_STATEMENT_TIMEOUT is not set' do
      it 'sets the statement timeout to 200ms' do
        expect(statement_timeout).to include '200ms'
      end
    end

    context 'when DATABASE_STATEMENT_TIMEOUT is set' do
      before { ENV['DATABASE_STATEMENT_TIMEOUT'] = '750' }
      after { ENV['DATABASE_STATEMENT_TIMEOUT'] = nil }

      it 'sets the statement timeout to the value in ms' do
        expect(statement_timeout).to include '750ms'
      end
    end

    context 'when running migrations' do
      let(:migration_dir) { app_path.join('db', 'migrate') }
      let(:migration_path) { migration_dir.join("#{Time.now.to_i}_test_timeout.rb") }
      let(:migration) do
        major, minor, * = Gem::Version.new(Rails::VERSION::STRING).segments
        version = "[#{major}.#{minor}]" if major >= 5
        <<-EOF
          class TestTimeout < ActiveRecord::Migration#{version}
            def up
              ActiveRecord::Base.connection.execute('SELECT pg_sleep(1)')
            end

            def down
              ActiveRecord::Base.connection.execute('SELECT pg_sleep(1)')
            end
          end
        EOF
      end

      let(:migrate) { app_helper.shell_run "cd #{app_path} && rake db:migrate" }
      let(:rollback) { app_helper.shell_run "cd #{app_path} && rake db:rollback" }

      before do
        FileUtils.mkdir_p(migration_dir)
        File.write(migration_path, migration)
      end
      after { File.delete(migration_path) }

      it 'should allow migration statements longer than the regular timeout' do
        expect { migrate }.to_not raise_error
      end
      it 'should allow rollback statements longer than the regular timeout' do
        expect { rollback }.to_not raise_error
      end
    end
  end
end
