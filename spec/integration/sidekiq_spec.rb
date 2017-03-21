require 'spec_helper'
require 'spec/support/run_test_app'

describe 'Sidekiq Setup' do
  run_test_app
  let(:app_options) { { keep_scaffold_directory: true } }
  before { app.wait_start }

  context 'When booting' do
    let(:middleware) { app_helper.rake_command('middleware') }
    it 'does not insert hirefire into the middleware stack' do
      expect(middleware).not_to include 'HireFire::Middleware'
    end
    context "if HIREFIRE_TOKEN is set" do
      before do
        app_helper.append_to_file scaffold_path.join('.env'), "\nHIREFIRE_TOKEN=hello"
      end
      it 'inserts hirefire into the middleware stack' do
        expect(middleware).to include 'HireFire::Middleware'
      end
    end
  end
end
