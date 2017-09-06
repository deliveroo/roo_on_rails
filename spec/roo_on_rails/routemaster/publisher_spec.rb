require 'active_support/core_ext/string'
require 'roo_on_rails/routemaster/publisher'
require 'support/test_model'

RSpec.describe RooOnRails::Routemaster::Publisher do
  TestPublisherA = Class.new(RooOnRails::Routemaster::Publisher)
  TestPublisherB = Class.new(RooOnRails::Routemaster::Publisher)
  let(:model) { TestModel.new }
  let(:event) { :noop }

  before do
    allow(::RooOnRails::Config).to receive(:routemaster_publishing_enabled?) { true }
  end

  describe 'when configured correctly' do
    let(:publisher) { TestPublisherA.new(model, event) }

    before do
      allow(publisher).to receive_messages(
        url: "https://deliveroo.test/url",
        data: { test_key_1: "Test value 1", test_key_2: "Test value 2" }
      )
    end

    it 'should publish an event to Routemaster fine' do
      expect(::Routemaster::Client).to receive(:send).with(
        :noop,
        "test_models",
        "https://deliveroo.test/url",
        {
          async: false,
          data: {
            "test_key_1" => "Test value 1",
            "test_key_2" => "Test value 2"
          },
          t: nil
        }
      )
      publisher.publish!
    end

    it 'should have a topic named after the model class' do
      expect(publisher.topic).to eq("test_models")
    end

    it 'should have the correct URL' do
      expect(publisher.url).to eq("https://deliveroo.test/url")
    end

    it 'should default to publishing synchronously' do
      expect(publisher).to_not be_async
    end

    it 'should have the correct event type' do
      expect(publisher.created?).to eq(false)
      expect(publisher.updated?).to eq(false)
      expect(publisher.deleted?).to eq(false)
      expect(publisher.noop?).to eq(true)
    end

    describe 'the timestamp of the event sent to routemaster' do
      subject(:timestamp) do
        ts = nil
        expect(::Routemaster::Client).to receive(:send) { |_, _, _, opts| ts = opts[:t] }
        publisher.publish!
        ts
      end

      context 'when the model was created' do
        let(:event) { :created }

        context 'when the model responds to created_at' do
          let(:create_time) { Time.at(12345) }
          let(:model) { TestModel.which_responds_to(created_at: create_time).new }

          it { should eq create_time.to_i }
        end

        context 'when the model does not respond to created_at' do
          # it { should eq nil }

          context 'when the model responds to updated_at' do
            let(:update_time) { Time.at(23456) }
            let(:model) { TestModel.which_responds_to(updated_at: update_time).new }

            it { should eq update_time.to_i }
          end
        end
      end

      context 'when the model was updated' do
        let(:event) { :updated }

        context 'when the model does not respond to updated_at' do
          it { should eq nil }
        end

        context 'when the model responds to updated_at' do
          let(:update_time) { Time.at(34567) }
          let(:model) { TestModel.which_responds_to(updated_at: update_time).new }

          it { should eq update_time.to_i }
        end
      end
    end
  end

  describe 'when missing some configuration' do
    let(:publisher) { TestPublisherB.new(model, event) }

    it '#url should raise an error' do
      expect { publisher.url }.to raise_error(NotImplementedError)
    end
  end
end
