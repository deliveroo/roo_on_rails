require 'spec_helper'
require 'spec/support/run_test_app'
require 'active_record'

if ActiveRecord::VERSION::MAJOR >= 4
  describe 'Database setup' do
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
    end
  end
end
