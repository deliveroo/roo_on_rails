require 'roo_on_rails/routemaster/publish_lifecycle_events'
require 'roo_on_rails/routemaster/publishers'
require 'roo_on_rails/routemaster/publisher'

RSpec.describe RooOnRails::Routemaster::PublishLifecycleEvents do
  subject do
    Class.new do
      @after_commit_hooks = []

      def self.after_commit_hooks
        @after_commit_hooks
      end

      def self.after_commit(*args)
        @after_commit_hooks << args
      end

      include RooOnRails::Routemaster::PublishLifecycleEvents
    end
  end

  it "adds three event hooks" do
    expect(subject.after_commit_hooks).to match_array([
      [:publish_lifecycle_event_on_create, { on: :create }],
      [:publish_lifecycle_event_on_update, { on: :update }],
      [:publish_lifecycle_event_on_destroy, { on: :destroy }]
    ])
  end
end
