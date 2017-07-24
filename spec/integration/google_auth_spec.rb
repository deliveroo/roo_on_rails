require 'spec_helper'
require 'spec/support/run_test_app'

RSpec.describe 'Google OAuth' do
  run_test_app
  before { app.wait_start }

  before { ENV['GOOGLE_AUTH_ENABLED'] = 'YES' }
  after  { ENV['GOOGLE_AUTH_ENABLED'] = 'NO' }

  describe 'middleware' do
    let(:output) { app_helper.shell_run "cd #{app_path} && rake middleware" }

    context "if Google Auth has been enabled" do
      it 'inserts OmniAuth into the middleware stack' do
        expect(output).to include 'OmniAuth::Builder'
      end
    end
  end

  describe 'routes' do
    let(:output) { app_helper.shell_run "cd #{app_path} && rake routes" }

    context "if Google Auth has been enabled" do
      it 'adds the callback route' do
        expect(output).to include '/auth/google_oauth2/callback'
      end

      it 'adds the failure route' do
        expect(output).to include '/auth/failure'
      end
    end
  end
end
