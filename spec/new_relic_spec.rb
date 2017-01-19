require 'spec_helper'
require 'spec/support/run_test_app'

describe 'New Relic integration' do
  run_test_app

  before { app.start }

  context 'with correct setup' do
    it 'loads New Relic' do
      app.wait_log /NewRelic.*Finished instrumentation/
    end
  end


  shared_examples 'abort early' do |message|
    it 'fails to load' do
      app.wait_log /Exiting/
      app.stop
      expect(app.status).not_to be_success
    end

    it 'logs the failure' do
      app.wait_log message
    end
  end


  context 'when NEW_RELIC_LICENSE_KEY is missing' do
    before do
      app_helper.comment_lines app_path.join('.env'), /NEW_RELIC_LICENSE_KEY/
    end
  
    include_examples 'abort early', /NEW_RELIC_LICENSE_KEY is required/
  end


  context 'when a newrelic.yml exists' do
    %w[. ./config].each do |path|
      context "in directory #{path}" do
        before do
          app_helper.create_file app_path.join(path).join('newrelic.yml'), <<~EOF
            # fake new relic config file
          EOF
        end
      
        include_examples 'abort early', /newrelic.yml detected/
      end
    end
  end
end
