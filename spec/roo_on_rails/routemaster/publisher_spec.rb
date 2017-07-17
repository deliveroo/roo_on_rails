require 'active_support/core_ext/string'
require 'roo_on_rails/routemaster/publisher'

RSpec.describe RooOnRails::Routemaster::Publisher do
  class TestPublisher < RooOnRails::Routemaster::Publisher
    def url
      "https://deliveroo.test/url"
    end

    def data
      {
        test_key_a: "Test value A",
        test_key_b: "Test value B"
      }
    end
  end

  TestModel = Class.new
  let(:model) { TestModel.new }
  let(:event) { :noop }
  let(:publisher) { TestPublisher.new(model, event) }

  it 'should be publishable' do
    expect(publisher.publish?).to eq(true)
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
