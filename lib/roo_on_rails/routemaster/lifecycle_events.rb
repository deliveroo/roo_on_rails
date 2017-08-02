require 'active_support/concern'
require 'new_relic/agent'
require 'roo_on_rails/routemaster/publishers'

module RooOnRails
  module Routemaster
    module LifecycleEvents
      extend ActiveSupport::Concern

      ACTIVE_RECORD_TO_ROUTEMASTER_EVENT_MAP = {
        create: :created,
        update: :updated,
        destroy: :deleted,
        noop: :noop
      }.freeze
      private_constant :ACTIVE_RECORD_TO_ROUTEMASTER_EVENT_MAP

      def publish_lifecycle_event(event)
        publishers = Routemaster::Publishers.for(self, routemaster_event_type(event))
        publishers.each do |publisher|
          begin
            publisher.publish!
          rescue => e
            NewRelic::Agent.notice_error(e)
          end
        end
      end

      private

      def routemaster_event_type(event)
        ACTIVE_RECORD_TO_ROUTEMASTER_EVENT_MAP[event].tap do |type|
          raise "invalid lifecycle event '#{event}'" unless type
        end
      end

      def publish_lifecycle_event_on_create
        publish_lifecycle_event :create
      end

      def publish_lifecycle_event_on_update
        publish_lifecycle_event :update
      end

      def publish_lifecycle_event_on_destroy
        publish_lifecycle_event :destroy
      end

      def publish_lifecycle_event_on_noop
        publish_lifecycle_event :noop
      end

      module ClassMethods
        def publish_lifecycle_events(*events)
          events = events.any? ? events : %i(create update destroy)
          events.each do |event|
            after_commit(
              :"publish_lifecycle_event_on_#{event}",
              on: event
            )
          end
        end
      end
    end
  end
end
