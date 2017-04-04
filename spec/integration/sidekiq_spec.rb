require 'spec_helper'
require 'spec/support/run_test_app'

describe 'Sidekiq Setup' do
  run_test_app
  before { app.wait_start }

  context 'When booting' do
    let(:middleware) { app_helper.shell_run "cd #{app_path} && rake middleware" }
    it 'does not insert hirefire into the middleware stack' do
      expect(middleware).not_to include 'HireFire::Middleware'
    end
    context "if HIREFIRE_TOKEN is set" do
      before do
        app_helper.append_to_file app_path.join('.env'), "\nHIREFIRE_TOKEN=hello"
      end
      it 'inserts hirefire into the middleware stack' do
        expect(middleware).to include 'HireFire::Middleware'
      end
    end
  end
end

describe "sidekiq loader" do
  run_sidekiq
  before { app.wait_start }

  it 'starts and stops the app cleanly' do
    app.start.wait_start
    app.stop
    expect(app.status).to be_success
  end

end
