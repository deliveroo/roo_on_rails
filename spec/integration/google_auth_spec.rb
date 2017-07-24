require 'spec_helper'
require 'spec/support/run_test_app'
require 'roo_on_rails/config'

RSpec.describe 'Google Auth setup' do
  run_test_app
  before { app.wait_start }

  context 'when booting' do
    let(:middleware) { app_helper.shell_run "cd #{app_path} && rake middleware" }

    context "if Google Auth has not been enabled" do
      it 'does not insert OmniAuth into the middleware stack' do
        expect(middleware).to_not include 'OmniAuth::Builder'
      end
    end

    context "if Google Auth has been enabled" do
      let(:app_env_vars) { ["GOOGLE_AUTH_ENABLED=TRUE", super()].join("\n") }

      it 'inserts OmniAuth into the middleware stack' do
        expect(middleware).to include 'OmniAuth::Builder'
      end
    end
  end
end
