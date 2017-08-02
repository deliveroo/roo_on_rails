require 'spec_helper'
require 'spec/support/run_test_app'

describe 'Routemaster Client' do
  run_test_app

  before { app.wait_start }
  after  { ENV['ROUTEMASTER_ENABLED'] = 'false' }

  describe 'when booting the app' do
    let(:output) { app_helper.shell_run "cd #{app_path} && rake middleware" }

    it 'does not insert Routemaster Client into the middleware stack' do
      expect(output).not_to include 'Routemaster::Client'
    end

    context 'if ROUTEMASTER_ENABLED is true' do
      before { ENV['ROUTEMASTER_ENABLED'] = 'true' }

      context 'and ROOBUS_URL/ROOBUS_UUID are not set' do
        it 'the app fails to load' do
          app.wait_log /Exiting/
          app.stop
          expect(app.status).not_to be_success
        end

        it 'the app logs the failure' do
          app.wait_log /ROOBUS_URL and ROOBUS_UUID are required/
        end
      end

      context 'and ROOBUS_URL/ROOBUS_UUID are set' do
        before do
          ENV['ROOBUS_URL'] = 'https://routemaster.dev'
          ENV['ROOBUS_UUID'] = 'demo'
        end

        it 'inserts Routemaster Client into the middleware stack' do
          app.wait_start
          expect(output).to include 'Routemaster::Client'
        end
      end

      it 'inserts Routemaster Client into the middleware stack' do
        expect(output).to include 'Routemaster::Client'
      end
    end
  end
end
