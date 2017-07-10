require 'spec_helper'
require 'spec/support/run_test_app'
require 'roo_on_rails/config'

RSpec.describe 'Google Auth setup' do
  run_test_app
  before { app.wait_start }

  context 'when booting' do
    let(:middleware) { app_helper.shell_run "cd #{app_path} && rake middleware" }

    context "if Google Auth has been enabled" do
      before do
        allow(RooOnRails::Config).to receive(:google_auth_enabled?) { true }
      end

      it 'inserts OmniAuth into the middleware stack' do     
        expect(middleware).to include 'OmniAuth::Builder'
      end
    end

    context "if Google Auth has NOT been enabled" do
      before do
        allow(RooOnRails::Config).to receive(:google_auth_enabled?) { false }
      end

      it 'does NOT insert OmniAuth into the middleware stack' do     
        expect(middleware).to_not include 'OmniAuth::Builder'
      end
    end
  end
end
