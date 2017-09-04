# An active-model-like class which is used in tests
class TestModel

  # This means #will_publish? will always be true
  def new_record?
    true
  end

  # Defines a new test model which will respond to the given
  # methods.
  #
  # @example:
  #   m = TestModel.which_responds_to(updated_at: -> { Time.now })
  #
  #   m.new.updated_at
  #   # => 2017-09-01 13:26:18 +0100
  def self.which_responds_to(**methods_and_repsonses)
    Class.new(self) do
      def self.name
        'AnonymousTestModelClass'
      end

      methods_and_repsonses.each do |method_name, response|
        block = response.respond_to?(:call) ? response : -> { response }
        define_method(method_name, &block)
      end
    end
  end
end

