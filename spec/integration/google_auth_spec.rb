require 'spec_helper'
require 'spec/support/run_test_app'

RSpec.describe 'Google OAuth' do
  build_test_app
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
    let(:output) { app_helper.shell_run "cd #{app_path} && rails routes" }

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

  describe 'other middleware' do
    before do
      app_helper.create_file app_path.join('config/initializers/deflater.rb'), %{
        require 'rack/deflater'
        Rails.application.config.middleware.use Rack::Deflater
      }
    end

    let(:output) { app_helper.shell_run "cd #{app_path} && rake middleware" }

    it 'allows for other middleware' do
      expect(output).to include('Rack::Deflater')
    end
  end

end
