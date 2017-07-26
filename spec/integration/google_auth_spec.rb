require 'spec_helper'
require 'spec/support/run_test_app'

RSpec.describe 'Google OAuth', rails_min_version:  5 do
  run_test_app
  before { app.wait_start }

  after  { ENV['GOOGLE_AUTH_ENABLED'] = 'NO' }

  describe 'middleware' do
    let(:output) { app_helper.shell_run "cd #{app_path} && rake middleware" }

    context "if Google Auth has been enabled" do
      before { ENV['GOOGLE_AUTH_ENABLED'] = 'YES' }

      it 'inserts OmniAuth into the middleware stack' do
        expect(output).to include 'OmniAuth::Builder'
      end
    end

    context 'by default' do
      it 'does not insert OmniAuth into the middleware stack' do
        expect(output).not_to include 'OmniAuth::Builder'
      end
    end
  end

  describe 'routes' do
    let(:output) { app_helper.shell_run "cd #{app_path} && rake routes" }

    context "if Google Auth has been enabled" do
      before { ENV['GOOGLE_AUTH_ENABLED'] = 'YES' }

      it 'adds the callback route' do
        expect(output).to include '/auth/google_oauth2/callback'
      end

      it 'adds the failure route' do
        expect(output).to include '/auth/failure'
      end
    end

    context 'by default' do
      it 'does not add the callback route' do
        expect(output).not_to include '/auth/google_oauth2/callback'
      end
    end
  end
end
