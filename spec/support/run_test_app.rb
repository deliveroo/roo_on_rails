require 'spec/support/build_test_app'
require 'spec/support/sub_process'

module ROR
  module RunTestApp

    def run_test_app
      build_test_app

      let(:app_env) { 'production' }
      let(:app) {
        ROR::SubProcess.new(
          name:     'rails',
          dir:      app_path,
          # This ugly line forces the test app to run with unbuffered IO
          # The old line was `bundle exec rails server puma ...`
          command:  'bundle exec ruby -e STDOUT.sync=true -e \'load($0=ARGV.shift)\' bin/rails server -u puma -e %s' % app_env,
          start:    /Use Ctrl-C to stop/,
          stop:     /- Goodbye!/)
      }

      after { app.terminate }

      after do |example|
        app.dump_logs if example.exception
      end
    end

    def run_sidekiq
      build_test_app

      let(:app_env) { 'production' }
      let(:app) {
        ROR::SubProcess.new(
          name:     'sidekiq',
          dir:      app_path,
          command:  'bundle exec roo_on_rails sidekiq',
          start:    /Starting processing, hit Ctrl-C to stop/,
          stop:     /Bye!/)
      }

      after { app.terminate }
    end
  end
end


RSpec.configure do |config|
  config.extend ROR::RunTestApp
end
