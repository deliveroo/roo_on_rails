require 'spec_helper'
require 'support/check'
require 'roo_on_rails/checks/papertrail/token'

describe RooOnRails::Checks::Papertrail::Token, type: :check do
  class FakeClient
    def initialize(*)
    end
  end

  let(:client) { double 'PapertrailClient' }
  let(:token) { 'f00b4r' }

  subject { described_class.new(env: 'production', shell: shell, context: context, papertrail_client: FakeClient) }

  before do
    context.papertrail!.client = client
    shell.stub 'git config papertrail.token', output: token
    allow_any_instance_of(FakeClient).to receive(:list_destinations).
      and_return([])
  end

  context 'when all is configured' do
    it_expects_check_to_pass
  end

  context 'when no token exists' do
    let(:token) { '' }

    it_expects_check_to_fail
  end

  context 'when not authenticated to Papertrail' do
    before do
      allow_any_instance_of(FakeClient).to receive(:list_destinations).
        and_raise(Faraday::ClientError.new 'oh noes')
    end

    it_expects_check_to_fail
  end
end
