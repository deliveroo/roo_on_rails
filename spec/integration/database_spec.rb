require 'spec_helper'
require 'spec/support/run_test_app'
require 'active_record'

describe 'Database setup', rails_min_version: 4 do
  run_test_app

  context 'with a postgresql database' do
    context 'when ActiveRecord enabled' do
      let(:app_options) {{ database: 'postgresql' }}
      let(:database_file) { Pathname.new(__FILE__).join('../../support/database.yml') }

      let(:database_config) { database_file.read }
  
      before do
        app_path.join('config/database.yml').tap do |db_yml|
          app_helper.remove_file(db_yml)
          app_helper.create_file(db_yml, database_config)
        end
      end

      after { app.stop }

      context 'when DATABASE_STATEMENT_TIMEOUT is not set' do
        let(:database_config) { database_file.read.sub('statement_timeout: 200', '') }

        it 'raises an error' do
          expect { app.start.wait_start }.to raise_error

          # The subprocess does not raise the real error so the
          # only way to check is via the logs
          expect(app.has_log?(/DATABASE_STATEMENT_TIMEOUT not set/)).to be true
        end
      end

      context 'when DATABASE_STATEMENT_TIMEOUT is set' do
        it 'boots the app' do
          expect { app.start.wait_start }.not_to raise_error
        end
      end
    end
  end

  context 'with ActiveRecord disabled' do
    let(:app_options) {{ database: nil }}

    after { app.stop }

    it 'boots the app without errors' do
      app.start.wait_start
    end
  end
end
