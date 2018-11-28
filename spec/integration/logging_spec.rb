require 'spec_helper'
require 'spec/support/run_test_app'

RSpec.describe 'Logging Railtie' do
  run_test_app

  before do
    app.start
  end

  describe 'log_level' do
    before do
      app_helper.gsub_file app_path.join('config/environments/production.rb'),
        /config\.log_level = :debug/,
        'config.log_level = :info'

      app_helper.create_file app_path.join('config/initializers/debug.rb'),
        "Rails.logger.debug('d3bug')"

      app_helper.create_file app_path.join('config/initializers/info.rb'),
        "Rails.logger.info('inf0')"

      app_helper.create_file app_path.join('config/initializers/warn.rb'),
        "Rails.logger.warn('w4rn')"
    end

    context 'when LOG_LEVEL is unset' do
      it "uses the log level of `config.log_level`" do
        app.wait_start
        expect(app).not_to have_log(/d3bug/)
        expect(app).to have_log(/inf0/)
        expect(app).to have_log(/w4rn/)
      end
    end

    context 'when LOG_LEVEL is set' do
      let(:app_env_vars) {
        [super(), "LOG_LEVEL=#{log_level}"].join("\n")
      }

      context 'LOG_LEVEL is valid' do
        let(:log_level) { 'WARN' }

        it "uses LOG_LEVEL" do
          app.wait_start
          expect(app).not_to have_log(/d3bug/)
          expect(app).not_to have_log(/inf0/)
          expect(app).to have_log(/w4rn/)
        end
      end

      context 'LOG_LEVEL is invalid' do
        let(:log_level) { 'WASHING_MACHINE' }

        it "uses the log level of `config.log_level`" do
          app.wait_start
          expect(app).not_to have_log(/d3bug/)
          expect(app).to have_log(/inf0/)
          expect(app).to have_log(/w4rn/)
        end
      end
    end
  end
end
