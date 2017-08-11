module RooOnRails
  module Routemaster
    module Publishers
      @default_publishers = []
      @publishers = {}

      def self.register_default(publisher_class)
        @default_publishers << publisher_class
      end

      def self.register(publisher_class, model_class:)
        @publishers[model_class] ||= Set.new
        @publishers[model_class] << publisher_class
      end

      def self.for(model, event)
        publisher_classes = @publishers[model.class] || @default_publishers
        publisher_classes.map { |c| c.new(model, event) }
      end

      def self.clear
        @default_publishers = []
        @publishers = {}
      end
    end
  end
end
