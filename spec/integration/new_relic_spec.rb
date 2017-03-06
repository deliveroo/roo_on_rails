require 'spec_helper'
require 'spec/support/run_test_app'

describe 'New Relic integration' do
  run_test_app

  before { app.start }

  shared_examples 'loads' do
    it 'loads New Relic' do
      app.wait_start
      expect(app).to have_log /NewRelic.*Finished instrumentation/
    end
  end

  shared_examples 'does not load' do
    it 'does not load New Relic' do
      app.wait_start
      expect(app).not_to have_log /NewRelic.*Finished instrumentation/
    end

    it 'does not abort' do
      app.wait_start.stop
      expect(app.status).to be_success
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


  context 'with correct setup' do
    include_examples 'loads'
  end

  context 'when NEW_RELIC_LICENSE_KEY is missing' do
    before do
      app_helper.comment_lines app_path.join('.env'), /NEW_RELIC_LICENSE_KEY/
    end
  
    context 'in the test environment' do
      let(:app_env) { 'test' }

      include_examples 'does not load'
    end

    context 'in the development environment' do
      let(:app_env) { 'development' }
      after { app.stop }
      include_examples 'loads'
    end

    context 'in the production environment' do
      include_examples 'abort early', /NEW_RELIC_LICENSE_KEY must be set/
    end
  end


  context 'when a newrelic.yml exists' do
    %w[. ./config].each do |path|
      context "in directory #{path}" do
        before do
          app_helper.create_file app_path.join(path).join('newrelic.yml'), %{
            # fake new relic config file
          }
        end
      
        include_examples 'abort early', /newrelic.yml detected/
      end
    end
  end
end
