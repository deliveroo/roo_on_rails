require 'spec_helper'
require 'spec/support/run_test_app'
require 'active_record'

describe 'Database setup' do
  run_test_app
  let(:app_options) { { keep_scaffold_directory: true } }

  before { app.wait_start }

  context 'When booting' do
    before { app_helper.rake_command('db:create') }
    after { app_helper.rake_command('db:drop') }

    let(:statement_timeout) { app_helper.rake_command('db:statement_timeout') }

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
