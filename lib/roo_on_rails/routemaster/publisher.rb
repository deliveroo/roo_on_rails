require 'routemaster/client'

module RooOnRails
  module Routemaster
    class Publisher
      attr_reader :model, :event

      def initialize(model, event, client: ::Routemaster::Client)
        @model = model
        @event = event
        @client = client
      end

      def publish?
        true
      end

      def publish!
        @client.send(event, topic, url, data: stringify_keys(data)) if publish?
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

      def stringify_keys(hash)
        return hash if hash.nil? || hash.empty?

        hash.each_with_object({}) do |(k, v), h|
          h[k.to_s] = v.is_a?(Hash) ? stringify_keys(v) : v
        end
      end
    end
  end
end
