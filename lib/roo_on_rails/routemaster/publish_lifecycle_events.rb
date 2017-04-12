require 'active_support/concern'
require 'new_relic/agent'

module RooOnRails
  module Routemaster
    module PublishLifecycleEvents
      extend ActiveSupport::Concern

      ROUTEMASTER_EVENT_TYPE_MAP = {
        create: :created,
        update: :updated,
        destroy: :deleted,
        noop: :noop
      }.freeze
      private_constant :ROUTEMASTER_EVENT_TYPE_MAP

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
        ROUTEMASTER_EVENT_TYPE_MAP[event].tap do |type|
          raise "invalid lifecycle event '#{event}'" unless type
        end
      end

      module ClassMethods
        def publish_lifecycle_events(*events)
          events ||= %i[create update destroy]
          events.each do |event|
            after_commit(
              -> { publish_lifecycle_event(event) },
              on: event
            )
          end
        end
      end
    end
  end
end
