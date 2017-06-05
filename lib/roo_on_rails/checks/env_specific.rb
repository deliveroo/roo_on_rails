require 'roo_on_rails/checks/base'

module RooOnRails
  module Checks
    # Base class for checks that are applicable per-environment.
    # The `env` passed to the initializer becomes part of the check signature.
    class EnvSpecific < Base
      attr_reader :env

      def initialize(**options)
        super(options)
        @env = @options[:env]
      end

      def signature
        super + [@env]
      end
    end
  end
end
