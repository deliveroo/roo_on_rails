require 'spec_helper'
require 'spec/support/run_test_app'

describe 'Http rack setup' do
  run_test_app
  before { app.wait_start }

  context 'When booting' do
    let(:middleware) { app_helper.shell_run "cd #{app_path} && rake middleware" }

    it 'inserts rack timeout into the middleware stack' do
      expect(middleware).to include 'Rack::Timeout'
    end

    it 'inserts safe timeout into the middleware stack' do
      expect(middleware).to include 'RooOnRails::Rack::SafeTimeouts'
    end

    it 'inserts deflate into the middleware stack' do
      expect(middleware).to include 'Rack::Deflater'
    end

    context 'if ROO_ON_RAILS_RACK_DEFLATE is set to NO' do
      before { ENV['ROO_ON_RAILS_RACK_DEFLATE'] = 'NO' }
      after { ENV['ROO_ON_RAILS_RACK_DEFLATE'] = nil }

      it 'does not insert deflate into the middleware stack' do
        expect(middleware).not_to include 'Rack::Deflater'
      end
    end
  end
end
