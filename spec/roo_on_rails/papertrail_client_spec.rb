require 'spec_helper'
require 'roo_on_rails/papertrail_client'

describe RooOnRails::PapertrailClient, webmock: true do
  let(:token) { 'deadbeef' }
  subject { described_class.new token: token }

  shared_examples 'an endpoint' do |options|
    before { stub_request(:any, //) }

    it "makes a #{options[:method]} request to the expected URL" do
      perform
      expect(WebMock).to have_requested(options[:method], url).with(
        headers: { 'X-Papertrail-Token' => 'deadbeef' }
      )
    end


  end

  describe '#list_destinations' do
    let(:perform) { subject.list_destinations }
    let(:url) { 'https://papertrailapp.com/api/v1/destinations.json' }

    it_behaves_like 'an endpoint', method: :get
  end

  describe '#list_systems' do
    let(:perform) { subject.list_systems }
    let(:url) { 'https://papertrailapp.com/api/v1/systems.json' }

    it_behaves_like 'an endpoint', method: :get
  end

  describe '#get_system' do
    let(:perform) { subject.get_system(1234) }
    let(:url) { 'https://papertrailapp.com/api/v1/systems/1234.json' }

    it_behaves_like 'an endpoint', method: :get
  end

  describe '#update_system' do
    let(:perform) { subject.update_system(1234, name: 'bugbear') }
    let(:url) { 'https://papertrailapp.com/api/v1/systems/1234.json' }

    it_behaves_like 'an endpoint', method: :put
  end

end
