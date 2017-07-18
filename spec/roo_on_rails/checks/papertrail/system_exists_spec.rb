require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/papertrail/system_exists'

describe RooOnRails::Checks::Papertrail::SystemExists, type: :check do
  let(:client) { double 'PapertrailClient' }

  subject { described_class.new(env: 'production', shell: shell, context: context) }

  def mashify(obj)
    case obj
    when Array then obj.map { |o| mashify o }
    else Hashie::Mash.new(obj)
    end
  end

  before do
    context.papertrail!.client = client
    context.heroku!.app!.production = 'testapp-production'
    context.papertrail!.dest!.host = 'logs2.papertrailapp.com'
    context.papertrail.dest.port = 23526
    context.papertrail.system_name!.production = 'd.ba64a518-6689-441d-826c-e89875808244'

    allow(client).to receive(:list_systems).
      and_return(mashify existing_systems)
  end

  context 'when no matching systems exist' do
    let(:existing_systems) {[{
      'hostname' => 'd.d0ee08ab-8f33-463c-bb0a-b86020da2ae7'
    }]}

    it_expects_check_to_fail
  end

  context 'when exactly one partial match exists' do
    let(:existing_systems) {[{
      'hostname' => 'd.ba64a518-6689-441d-826c-e89875808244',
      'syslog' => {
        'port' => 12345,
        'hostname' => 'logs3.papertrailapp.com',
      },
    }]}

    it_expects_check_to_fail
  end

  context 'when exactly one match exists' do
    let(:existing_systems) {[{
      'id' => 450796,
      'hostname' => 'd.ba64a518-6689-441d-826c-e89875808244',
      'syslog' => {
        'port' => 23526,
        'hostname' => 'logs2.papertrailapp.com',
      },
    }]}

    it_expects_check_to_pass

    it { expect { perform }.to change { context.papertrail_.system_id_.production }.to 450796 }
  end
end
