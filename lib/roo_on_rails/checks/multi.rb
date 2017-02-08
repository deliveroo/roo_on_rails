module RooOnRails
  module Checks
    class Multi
      def initialize(variants:, of:)
        @_variants = variants
        @_of = of
      end

      def run(*args)
        @_variants.each do |v|
          @_of.new(v, *args).run
        end
      end
    end
  end
end

