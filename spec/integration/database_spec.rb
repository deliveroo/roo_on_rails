require 'spec_helper'
require 'spec/support/run_test_app'
require 'active_record'

describe 'Database setup', rails_min_version: 4 do
  run_test_app

  context 'with a postgresql database' do
    let(:app_options) {{ database: 'postgresql' }}
    let(:database_config) { Pathname.new(__FILE__).join('../../support/database.yml').read }

    before do
      app_path.join('config/database.yml').tap do |db_yml|
        app_helper.remove_file(db_yml)
        app_helper.create_file(db_yml, database_config)
      end
    end

    subject { app.wait_start }

    context 'when booting' do
      before { app_helper.shell_run "cd #{app_path} && rake db:create" }
      after  { app_helper.shell_run "cd #{app_path} && rake db:drop" }

      let(:statement_timeout) { app_helper.shell_run "cd #{app_path} && rake db:statement_timeout" }

      context 'when DATABASE_STATEMENT_TIMEOUT is not set' do
        before do
          database_config.sub('statement_timeout: 200', '')
        end

        it 'raises an error' do
          expect { subject }.to raise_error('DATABASE_STATEMENT_TIMEOUT not set')
        end
      end

      context 'when DATABASE_STATEMENT_TIMEOUT is set' do
        it 'boots the app' do
          expect { subject }.not_to raise_error
        end
      end
    end
  end

  context 'with ActiveRecord disabled' do
    let(:app_options) {{ database: nil }}

    it 'boots the app without errors' do
      app.start.wait_start
    end
  end
end
