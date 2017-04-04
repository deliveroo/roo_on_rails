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

    context 'if RAILS_ENV is not set to "test"' do
      it 'inserts rack enforcer into the middleware stack' do
        expect(middleware).to include 'Rack::SslEnforcer'
      end
    end

    context 'if RAILS_ENV is set to "test"' do
      before { ENV['RAILS_ENV'] = 'test' }
      after { ENV['RAILS_ENV'] = nil }

      it 'does not insert rack enforcer into the middleware stack' do
        expect(middleware).to_not include 'Rack::SslEnforcer'
      end
    end
  end
end
