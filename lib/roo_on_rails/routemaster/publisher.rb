require 'roo_on_rails/config'
require 'routemaster/client'

module RooOnRails
  module Routemaster
    class Publisher
      attr_reader :model, :event, :force_publish

      def initialize(model, event, client: ::Routemaster::Client, force_publish: false)
        @model = model
        @event = event
        @client = client
        @force_publish = force_publish
      end

      def publish?
        return true if force_publish
        noop? || @model.new_record? || @model.previous_changes.any?
      end

      def will_publish?
        Config.routemaster_publishing_enabled? && publish?
      end

      def publish!
        return unless will_publish?
        @client.send(
          @event,
          topic,
          url,
          async: async?,
          data: stringify_keys(data),
          t: timestamp && (timestamp.to_f * 1000).to_i
        )
      end

      def topic
        @model.class.name.tableize
      end

      def url
        raise NotImplementedError
      end

      def async?
        false
      end

      def data
        nil
      end

      def timestamp
        return @model.created_at if created? && @model.respond_to?(:created_at)
        return @model.updated_at if (updated? || created?) && @model.respond_to?(:updated_at)
        nil
      end

      %i(created updated deleted noop).each do |event_type|
        define_method :"#{event_type}?" do
          @event.to_sym == event_type
        end
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
