require 'roo_on_rails/routemaster/lifecycle_events'
require 'roo_on_rails/routemaster/publishers'
require 'roo_on_rails/routemaster/publisher'

RSpec.describe RooOnRails::Routemaster::LifecycleEvents do
  subject do
    Class.new do
      @after_commit_hooks = []

      def self.after_commit_hooks
        @after_commit_hooks
      end

      def self.after_commit(*args)
        @after_commit_hooks << args
      end

      include RooOnRails::Routemaster::LifecycleEvents
    end
  end

  let(:subject_instance) { subject.new }
  let(:publisher_spy) { spy('publisher') }

  events_and_types = [
    %i(create created),
    %i(update updated),
    %i(destroy deleted)
  ]

  describe "::publish_lifecycle_events" do
    context "when called without arguments" do
      before { subject.publish_lifecycle_events }

      it "adds three event hooks" do
        expect(subject.after_commit_hooks).to match_array([
          [:publish_lifecycle_event_on_create, { on: :create }],
          [:publish_lifecycle_event_on_update, { on: :update }],
          [:publish_lifecycle_event_on_destroy, { on: :destroy }]
        ])
      end

      describe "and calling a callback" do
        events_and_types.each do |lifecycle_event|
          it "fetches a publisher for #{lifecycle_event.first}" do
            callback = subject.after_commit_hooks.detect { |event| event.last[:on] == lifecycle_event.first }.first

            allow(RooOnRails::Routemaster::Publishers).to receive(:for).with(subject, lifecycle_event.last) do
              [publisher_spy]
            end

            expect(publisher_spy).to receive(:publish!)
            subject_instance.send(callback)
          end
        end
      end

      it "defines all three lifecycle events and noop on an instance" do
        expect {
          subject_instance.method(:publish_lifecycle_event_on_create)
          subject_instance.method(:publish_lifecycle_event_on_update)
          subject_instance.method(:publish_lifecycle_event_on_destroy)
          subject_instance.method(:publish_lifecycle_event_on_noop)
        }.to_not raise_error
      end
    end

    context "when called with a 'create' lifecycle event" do
      before { subject.publish_lifecycle_events(:create) }

      it "adds a 'create' hook only" do
        expect(subject.after_commit_hooks).to match_array([[:publish_lifecycle_event_on_create, { on: :create }]])
      end
    end
  end

  describe "#publish_lifecycle_event" do
    before do
      MockRaven = class_double("Raven", capture_exception: nil)
      stub_const("Raven", MockRaven)
    end

    events_and_types.each do |lifecycle_event|
      before do
        allow(RooOnRails::Routemaster::Publishers).to receive(:for).with(subject, lifecycle_event.last) do
          [publisher_spy]
        end
      end

      it "publishes #{lifecycle_event.first} event with force_publish disabled" do
        expect(publisher_spy).to receive(:publish!).with(force_publish: false)
        subject_instance.publish_lifecycle_event(lifecycle_event.first)
      end

      it 'reports with Raven on error' do
        allow(publisher_spy).to receive(:publish!).and_raise(StandardError)

        expect(Raven).to receive(:capture_exception).with(StandardError)
        subject_instance.publish_lifecycle_event(lifecycle_event.first)
      end
    end
  end

  describe "#publish_lifecycle_event!" do
    before do
      MockRaven = class_double("Raven", capture_exception: nil)
      stub_const("Raven", MockRaven)
    end

    events_and_types.each do |lifecycle_event|
      before do
        allow(RooOnRails::Routemaster::Publishers).to receive(:for).with(subject, lifecycle_event.last) do
          [publisher_spy]
        end
      end

      it "publishes #{lifecycle_event.first} event with force_publish enabled" do
        expect(publisher_spy).to receive(:publish!).with(force_publish: true)
        subject_instance.publish_lifecycle_event!(lifecycle_event.first)
      end

      it 'reports with Raven on error' do
        allow(publisher_spy).to receive(:publish!).and_raise(StandardError)

        expect(Raven).to receive(:capture_exception).with(StandardError)
        subject_instance.publish_lifecycle_event(lifecycle_event.first)
      end
    end
  end
end
