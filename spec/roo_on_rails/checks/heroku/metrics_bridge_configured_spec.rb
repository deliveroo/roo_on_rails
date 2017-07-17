require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/heroku/metrics_bridge_configured'

describe RooOnRails::Checks::Heroku::MetricsBridgeConfigured, type: :check do
  let(:client) { double 'PlatformAPI' }

  subject { described_class.new(env: 'production', shell: shell, context: context) }

  let(:bridge_app_config) {{
    'ALLOWED_APPS' => 'foobar-staging,foobar-production',
    'FOOBAR-PRODUCTION_PASSWORD' => 'secret',
    'FOOBAR-PRODUCTION_TAGS' => 'app:foobar-production',
  }}

  before do
    context.heroku!.api_client = client
    context.heroku!.app!.production = 'foobar-production'

    allow(client).to receive_message_chain(:config_var, :info_for_app).
      and_return(bridge_app_config)
  end

  describe '#call' do
    let(:bridge_app_config) {{
      'ALLOWED_APPS' => 'foobar-staging,foobar-production',
      'FOOBAR-PRODUCTION_PASSWORD' => 'secret',
      'FOOBAR-PRODUCTION_TAGS' => 'app:foobar-production',
    }}

    context 'when all is configured' do
      it_expects_check_to_pass

      it { expect { perform }.to change { context.heroku.metric_bridge_token_.production }.to 'secret' }
    end

    context 'when the app is not allowed yet' do
      before { bridge_app_config['ALLOWED_APPS'] = 'foobar-staging' }
      it_expects_check_to_fail
    end

    context 'when the bridge lacks credentials' do
      before { bridge_app_config.delete 'FOOBAR-PRODUCTION_PASSWORD' }
      it_expects_check_to_fail
    end

    context 'when the bridge lacks tags' do
      before { bridge_app_config.delete 'FOOBAR-PRODUCTION_TAGS' }
      it_expects_check_to_fail
    end
  end
end
