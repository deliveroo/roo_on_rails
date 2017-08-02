require 'routemaster/client'
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

      def self.pluralize_table_names
        true
      end

      def self.table_name
        "examples"
      end

      include RooOnRails::Routemaster::LifecycleEvents
      publish_lifecycle_events
    end
  end

 let(:publisher_spy){ spy('publisher')}

  describe "::publish_lifecycle_events" do
    context "when called without arguments" do
      let(:subject_instance){ subject.new }

      it "adds three event hooks" do
        expect(subject.after_commit_hooks).to match_array([
          [:publish_lifecycle_event_on_create, {:on=>:create}],
          [:publish_lifecycle_event_on_update, {:on=>:update}],
          [:publish_lifecycle_event_on_destroy, {:on=>:destroy}]
        ])
      end

      describe "when calling a callback" do
        [
          [:create, :created],
          [:update, :updated],
          [:destroy, :deleted]
        ].each do |lifecycle_event|
          it "fetches a publisher for #{lifecycle_event.first.to_s}" do
            callback = subject.after_commit_hooks.detect { |event| event.last[:on] == lifecycle_event.first }.first

            allow(RooOnRails::Routemaster::Publishers).to receive(:for).with(subject, lifecycle_event.last) { [publisher_spy] }
            expect(publisher_spy).to receive(:publish!)
            subject_instance.send(callback)
          end
        end
      end

      it "defines all three lifecycle events on an instance" do
        expect {
          subject_instance.method(:publish_lifecycle_event_on_create)
          subject_instance.method(:publish_lifecycle_event_on_update)
          subject_instance.method(:publish_lifecycle_event_on_destroy)
        }.to_not raise_error
      end
    end
  end
end
