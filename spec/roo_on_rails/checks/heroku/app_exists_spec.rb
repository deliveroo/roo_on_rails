require 'spec_helper'
require 'hashie'
require 'support/fake_shell'
require 'support/silencer'
require 'roo_on_rails/checks/heroku/app_exists'

describe RooOnRails::Checks::Heroku::AppExists do
  let(:shell) { FakeShell.new }
  let(:client) { double 'PlatformAPI' }
  let(:context) { Hashie::Mash.new }

  subject { described_class.new(env: 'production', shell: shell, context: context) }

  let(:perform) { silence_stream(STDOUT) { subject.run } }

  before do
    context.deps = {
      %w[RooOnRails::Checks::Git::Origin] => true,
      %w[RooOnRails::Checks::Heroku::Token] => true,
    }

    context.heroku!.api_client = client
    context.git_repo = 'fubar-app'

    allow(client).to receive_message_chain(:app, :list).
      and_return(existing_apps.map { |n| { 'name' => n } })
  end

  context 'when no apps exist' do
    let(:existing_apps) { [] }

    it { expect { perform }.to raise_error(RooOnRails::Checks::Failure) }
    it { expect { perform rescue nil }.not_to change { context } }
  end
  
  context 'when multiple matching apps exist' do
    let(:existing_apps) { %w[ fubar-app-production roo-fubar-app-production ] }

    it { expect { perform }.to raise_error(RooOnRails::Checks::FinalFailure) }
    it { expect { perform rescue nil }.not_to change { context } }
  end

  context 'when exactly one match exists' do
    let(:existing_apps) { %w[ fubar-app-production ] }

    it { expect { perform }.not_to raise_error }
    it { expect { perform }.to change { context.heroku.app_.production }.to 'fubar-app-production' }
  end
end
