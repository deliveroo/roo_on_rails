require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/papertrail/system_named'

describe RooOnRails::Checks::Papertrail::SystemNamed, type: :check do
  let(:client) { double 'PapertrailClient' }

  subject { described_class.new(env: 'production', shell: shell, context: context) }

  before do
    context.papertrail!.client = client
    context.heroku!.app!.production = 'testapp-production'
    context.papertrail.system_id!.production = 12345

    allow(client).to receive(:get_system).
      with(12345).
      and_return(Hashie::Mash.new existing_system)
  end

  context 'when the system has the wrong name' do
    let(:existing_system) {{
      'name' => 'testapp-foobar',
    }}

    it_expects_check_to_fail
  end

  context 'when exactly one match exists' do
    let(:existing_system) {{
      'name' => 'testapp-production',
    }}

    it_expects_check_to_pass
  end

  context 'call put on papertrail client' do
    let(:existing_system) {{
      'name' => 'testapp-production',
    }}

    before do
      expect(client).to receive(:update_system).
        with(12345, "testapp-production").
        and_return({})
    end

    it { expect { subject.fix }.to_not raise_error }
  end
end
