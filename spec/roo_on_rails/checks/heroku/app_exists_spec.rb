require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/heroku/app_exists'

describe RooOnRails::Checks::Heroku::AppExists, type: :check do
  let(:client) { double 'PlatformAPI' }

  subject { described_class.new(env: 'production', shell: shell, context: context) }

  before do
    context.heroku!.api_client = client
    context.git_repo = 'fubar-app'

    allow(client).to receive_message_chain(:app, :list).
      and_return(existing_apps.map { |n| { 'name' => n } })
  end

  context 'when no apps exist' do
    let(:existing_apps) { [] }
    it_expects_check_to_fail
  end

  context 'when multiple matching apps exist' do
    let(:existing_apps) { %w[ fubar-app-production fubar-app-prd ] }
    it_expects_check_to_fail
  end

  context 'when exactly one match exists' do
    let(:existing_apps) { %w[ fubar-app-production ] }
    it_expects_check_to_pass

    it { expect { perform }.to change { context.heroku.app_.production }.to 'fubar-app-production' }
  end

  context 'when exactly one match exists with acceptable env abbreviation' do
    let(:existing_apps) { %w[ fubar-app-prd ] }
    it_expects_check_to_pass

    it { expect { perform }.to change { context.heroku.app_.production }.to 'fubar-app-prd' }
  end

end
