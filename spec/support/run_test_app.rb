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
          command:  'bundle exec rails server puma -e %s' % app_env,
          start:    /Use Ctrl-C to stop/,
          stop:     /- Goodbye!/)
      }

      after { app.terminate }
    end
  end
end


RSpec.configure do |config|
  config.extend ROR::RunTestApp
end
