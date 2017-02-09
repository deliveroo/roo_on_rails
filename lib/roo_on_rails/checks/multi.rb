module RooOnRails
  module Checks
    class Multi
      def initialize(variants:, of:)
        @variants = variants
        @of = of
      end

      def run(*args)
        @variants.each do |v|
          @of.new(v, *args).run
        end
      end
    end
  end
end

