require 'roo_on_rails/routemaster/publisher'
require 'roo_on_rails/routemaster/publishers'

RSpec.describe RooOnRails::Routemaster::Publishers do
  TestModel = Class.new
  TestPublisherA = Class.new(RooOnRails::Routemaster::Publisher)
  TestPublisherB = Class.new(RooOnRails::Routemaster::Publisher)

  let(:publishers) { described_class }
  let(:model) { TestModel.new }
  let(:event) { :noop }

  describe '.for' do
    context 'when one publisher is registered for a model' do
      before do
        publishers.register(TestPublisherA, model_class: model.class)
      end

      it 'should return an instance of the registered publisher class' do
        expect(publishers.for(model, event).size).to eq 1
        expect(publishers.for(model, event).first.class).to eq TestPublisherA
      end
      it 'should have the model set on the publisher' do
        expect(publishers.for(model, event).first.model).to eq model
      end
      it 'should have the event set on the publisher' do
        expect(publishers.for(model, event).first.event).to eq event
      end
    end

    context 'when multiple publishers are registered for a model' do
      before do
        publishers.register(TestPublisherA, model_class: model.class)
        publishers.register(TestPublisherB, model_class: model.class)
      end

      it 'should return an instance of each registered publisher class' do
        expect(publishers.for(model, event).size).to eq 2
        expect(publishers.for(model, event).first.class).to eq TestPublisherA
        expect(publishers.for(model, event).last.class).to eq TestPublisherB
      end
      it 'should have the model set on the publishers' do
        expect(publishers.for(model, event).map(&:model).uniq).to eq [model]
      end
      it 'should have the event set on the publishers' do
        expect(publishers.for(model, event).map(&:event).uniq).to eq [event]
      end
    end
  end
end
