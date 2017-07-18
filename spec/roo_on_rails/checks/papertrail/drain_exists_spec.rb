require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/papertrail/drain_exists'

describe RooOnRails::Checks::Papertrail::DrainExists, type: :check do
  let(:client) { double 'PlatformAPI' }

  subject { described_class.new(env: 'production', shell: shell, context: context) }

  before do
    context.heroku!.api_client = client
    context.heroku.app!.production = 'testapp-production'
    context.papertrail!.dest!.host = 'logs2.papertrailapp.com'
    context.papertrail.dest.port = 23526

    allow(client).to receive_message_chain(:log_drain, :list).
      with('testapp-production').
      and_return(existing_drains)
  end

  context 'when no drains exist' do
    let(:existing_drains) { [] }
    it_expects_check_to_fail
  end

  context 'when multiple matching drains exist' do
    let(:existing_drains) {[{
      'url' => 'syslog+tls://logs2.papertrailapp.com:23526',
      'token' => 'd.20995f9f-2bb7-44e9-b10d-ebab325e9a51',
    }, {
      'url' => 'syslog+tls://logs2.papertrailapp.com:23526',
      'token' => 'd.fe5ecb8c-05bf-4b0a-b376-160be6ffc5c3',
    }]}

    it_expects_check_to_fail
  end

  context 'when exactly one match exists' do
    let(:existing_drains) {[{
      'url' => 'syslog+tls://logs2.papertrailapp.com:23526',
      'token' => 'd.fe5ecb8c-05bf-4b0a-b376-160be6ffc5c3',
    }]}

    it_expects_check_to_pass

    it { expect { perform }.to change { context.papertrail_.system_name_.production }.to 'd.fe5ecb8c-05bf-4b0a-b376-160be6ffc5c3' }
  end
end
