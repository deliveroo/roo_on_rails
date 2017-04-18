module RooOnRails
  module Routemaster
    class Publisher
      attr_reader :model, :event

      def initialize(model, event)
        @model = model
        @event = event
      end

      def publish?
        true
      end

      def publish!
        return unless publish?

        event_data = data # cache in case it isn't memoised
        event_data = recursive_stringify(event_data) if event_data

        routemaster.send(event, topic, url, data: event_data)
      end

      def topic
        @model.class.name.underscore.pluralize
      end

      def url
        raise NotImplementedError
      end

      def data
        nil
      end

      private

      def routemaster
        ::Routemaster::Client
      end

      def recursive_stringify(hash)
        hash.each_with_object({}) do |(k, v), h|
          h[k.to_s] = v.is_a?(Hash) ? recursive_stringify(v) : v
        end
      end
    end
  end
end
