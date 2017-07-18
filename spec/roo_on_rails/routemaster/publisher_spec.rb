require 'active_support/core_ext/string'
require 'roo_on_rails/routemaster/publisher'

RSpec.describe RooOnRails::Routemaster::Publisher do
  TestPublisherA = Class.new(RooOnRails::Routemaster::Publisher)
  TestPublisherB = Class.new(RooOnRails::Routemaster::Publisher)
  TestModel = Class.new
  let(:model) { TestModel.new }
  let(:event) { :noop }

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
        { data: {
          "test_key_1" => "Test value 1",
          "test_key_2" => "Test value 2"
        }}
      )
      publisher.publish!
    end

    it 'should have a topic named after the model class' do
      expect(publisher.topic).to eq("test_models")
    end

    it 'should have the correct URL' do
      expect(publisher.url).to eq("https://deliveroo.test/url")
    end

    it 'should have the correct event type' do
      expect(publisher.created?).to eq(false)
      expect(publisher.updated?).to eq(false)
      expect(publisher.deleted?).to eq(false)
      expect(publisher.noop?).to eq(true)
    end
  end

  describe 'when missing some configuration' do
    let(:publisher) { TestPublisherB.new(model, event) }

    it '#url should raise an error' do
      expect { publisher.url }.to raise_error(NotImplementedError)
    end
  end
end
