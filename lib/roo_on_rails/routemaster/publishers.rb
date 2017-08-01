module RooOnRails
  module Routemaster
    module Publishers
      @publishers = {}

      def self.register(publisher_class, model_class:)
        @publishers[model_class] ||= Set.new
        @publishers[model_class] << publisher_class
      end

      def self.for(model, event)
        publisher_classes = @publishers[model.class]
        publisher_classes.map { |c| c.new(model, event) }
      end
    end
  end
end