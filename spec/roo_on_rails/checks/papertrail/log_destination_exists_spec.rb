require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/papertrail/drain_exists'

describe RooOnRails::Checks::Papertrail::LogDestinationExists, type: :check do
  let(:client) { double 'PapertrailClient' }

  subject { described_class.new(env: 'production', shell: shell, context: context) }

  before do
    context.papertrail!.client = client

    allow(client).to receive(:list_destinations).
      and_return(existing_destinations)
  end

  context 'when no destinations exist' do
    let(:existing_destinations) { [] }
    it_expects_check_to_fail
  end

  context 'when exactly one match exists' do
    let(:existing_destinations) {[{
      'syslog' => {
        'description' => 'default',
        'port' => 1234,
        'hostname' => 'foo.com',
      }
    }]}

    it_expects_check_to_pass

    it { expect { perform }.to change { context.papertrail_.dest_.host }.to 'foo.com' }
    it { expect { perform }.to change { context.papertrail_.dest_.port }.to 1234 }
  end
end
