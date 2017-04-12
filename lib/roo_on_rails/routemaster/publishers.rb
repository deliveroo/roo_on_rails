module RooOnRails
  module Routemaster
    module Publishers
      @publishers = {}

      def self.register(publisher_class, model_class:, on: %i[created updated deleted noop])
        Array(on).each do |event|
          key = [model_class, event]
          @publishers[key] ||= Set.new
          @publishers[key] << publisher_class
        end
      end

      def self.for(model, event)
        publisher_classes = @publishers[[model.class, event]]
        publisher_classes.map { |c| c.new(model, event) }
      end
    end
  end
end
