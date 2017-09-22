require 'spec_helper'
require 'roo_on_rails/concerns/require_api_key'

RSpec.describe RooOnRails::Concerns::RequireApiKey do
  # This class is incredibly hard to test _as_ a controller concern as
  # we would have to instantiate an entire rails application in order to test the parts of
  # this concern which are already tested within rails, so the new authentication logic is
  # pulled out into the `Authenticator` class for testing.

  describe RooOnRails::Concerns::RequireApiKey::Authenticator do
    subject(:described_instance) { described_class.new(whitelisted_services) }

    let(:real_key) { 'apikey' }
    let(:stubbed_env) { {
      'SOME_SERVICE_CLIENT_KEY' => real_key,
      'SOME_OTHER_SERVICE_CLIENT_KEY' => real_key,
    } }

    before do
      allow(ENV).to receive(:select) do |&block|
        stubbed_env.select(&block)
      end
    end

    describe '#valid?' do
      subject(:described_method) { described_instance.valid?(given_service, given_key) }
      let(:given_service) { 'some_service' }
      let(:whitelisted_services) { [] }

      context 'when giving a valid client key' do
        let(:given_key) { real_key }

        it { should eq true }

        context 'when some services are whitelisted' do
          let(:whitelisted_services) { ['some_service'] }

          context 'when the given service is in the whitelist' do
            it { should eq true }
          end

          context 'when the given service is not in the whitelist' do
            let(:given_service) { 'some_other_service' }

            it { should eq false }
          end
        end
      end

      context 'when giving a invalid client key' do
        let(:given_key) { 'notcorrect' }

        it { should eq false }
      end
    end
  end
end