require 'roo_on_rails/routemaster/publisher'
require 'roo_on_rails/routemaster/publishers'
require 'support/test_model'

RSpec.describe RooOnRails::Routemaster::Publishers do
  TestPublisherA = Class.new(RooOnRails::Routemaster::Publisher)
  TestPublisherB = Class.new(RooOnRails::Routemaster::Publisher)

  let(:publishers) { described_class }
  let(:model) { TestModel.new }
  let(:event) { :noop }

  describe '.for' do
    before { publishers.clear }

    context 'when no publishers are registered for a model' do
      it 'should return an empty list of publishers' do
        expect(publishers.for(model, event)).to be_empty
      end
    end

    context 'when a default publisher is registered' do
      before do
        publishers.register_default(TestPublisherA)
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
      it 'should have force_publish set properly on the publisher' do
        expect(publishers.for(model, event).first.force_publish).to eq false
        expect(publishers.for(model, event, force_publish: false).first.force_publish).to eq false
        expect(publishers.for(model, event, force_publish: true).first.force_publish).to eq true
      end
    end

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
      it 'should have force_publish set properly on the publisher' do
        expect(publishers.for(model, event).first.force_publish).to eq false
        expect(publishers.for(model, event, force_publish: false).first.force_publish).to eq false
        expect(publishers.for(model, event, force_publish: true).first.force_publish).to eq true
      end
    end

    context 'when multiple default publishers are registered' do
      before do
        publishers.register_default(TestPublisherA)
        publishers.register_default(TestPublisherB)
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
      it 'should have force_publish set properly on the publisher' do
        expect(publishers.for(model, event).map(&:force_publish).uniq).to eq [false]
        expect(
          publishers.for(model, event, force_publish: false).map(&:force_publish).uniq
        ).to eq [false]
        expect(
          publishers.for(model, event, force_publish: true).map(&:force_publish).uniq
        ).to eq [true]
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
      it 'should have force_publish set properly on the publisher' do
        expect(publishers.for(model, event).map(&:force_publish).uniq).to eq [false]
        expect(
          publishers.for(model, event, force_publish: false).map(&:force_publish).uniq
        ).to eq [false]
        expect(
          publishers.for(model, event, force_publish: true).map(&:force_publish).uniq
        ).to eq [true]
      end
    end

    context 'when both a default publisher and a model-specific publisher are registered' do
      before do
        publishers.register_default(TestPublisherA)
        publishers.register(TestPublisherB, model_class: model.class)
      end

      it 'should return an instance of only the model-specific publisher' do
        expect(publishers.for(model, event).size).to eq 1
        expect(publishers.for(model, event).last.class).to eq TestPublisherB
      end
      it 'should have the model set on the publisher' do
        expect(publishers.for(model, event).first.model).to eq model
      end
      it 'should have the event set on the publisher' do
        expect(publishers.for(model, event).first.event).to eq event
      end
      it 'should have force_publish set properly on the publisher' do
        expect(publishers.for(model, event).map(&:force_publish).uniq).to eq [false]
        expect(
          publishers.for(model, event, force_publish: false).map(&:force_publish).uniq
        ).to eq [false]
        expect(
          publishers.for(model, event, force_publish: true).map(&:force_publish).uniq
        ).to eq [true]
      end
    end
  end
end
