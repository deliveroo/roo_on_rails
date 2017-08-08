require 'spec_helper'
require 'spec/support/run_test_app'

describe 'Routemaster Client' do
  run_test_app

  before { app.start }

  describe 'when booting the app' do
    it 'does not abort' do
      app.wait_start.stop
      expect(app.status).to be_success
    end

    context 'if ROUTEMASTER_ENABLED is true' do
      let(:app_env_vars) { ["ROUTEMASTER_ENABLED=true", super()].join("\n") }

      context 'and ROUTEMASTER_URL/ROUTEMASTER_UUID are not set' do
        it 'the app fails to load' do
          app.wait_log /Exiting/
          app.stop
          expect(app.status).not_to be_success
        end

        it 'the app logs the failure' do
          app.wait_log /ROUTEMASTER_URL and ROUTEMASTER_UUID are required/
        end
      end
    end
  end
end
