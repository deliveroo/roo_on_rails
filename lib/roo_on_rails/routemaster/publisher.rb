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

        options = { type: event, topic: topic, url: url }
        event_data = data # cache in case it isn't memoised
        options[:data] = recursive_stringify(event_data) if event_data.present?

        routemaster.send_event(**options)
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

      def routemaster
        raise NotImplementedError
      end

      private

      def recursive_stringify(hash)
        hash.each_with_object({}) do |(k, v), h|
          h[k.to_s] = v.is_a?(Hash) ? recursive_stringify(v) : v
        end
      end
    end
  end
end
