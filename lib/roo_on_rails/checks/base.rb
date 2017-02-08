require 'roo_on_rails/checks'
require 'roo_on_rails/checks/helpers'

module RooOnRails
  module Checks
    class Base
      include Helpers

      def self.run(**options)
        new(**options).run
      end

      def initialize(fix: false, state: nil)
        @fix = fix
        @state = state
      end

      def run
        say _intro
        _call
      rescue Failure
        raise unless @fix
        say "\t· attempting to fix", %i[yellow]
        _fix
        say "\t· re-checking", %i[yellow]
        _call
      end

      protected

      def _intro
        self.class.name
      end

      def _call
        _fail "this check wasn't implemented"
      end

      def _fix
        _fail "can't fix this on my own"
      end

      def _state
        @state
      end

      def _run(cmd)
        result = Bundler.with_clean_env { %x{#{cmd}} }
        return [$?.success?, result]
      end

      def _run!(cmd)
        Bundler.with_clean_env { system(cmd) }
        raise CommandFailed.new(cmd) unless $?.success?
      end

      def _run?(cmd)
        Bundler.with_clean_env { system(cmd) }
        $?.success?
      end

      def _ok(msg)
        say "\t✔ #{msg}", :green
      end

      def _fail(msg)
        say "\t✘ #{msg}", :red
        raise Failure
      end
    end
  end
end
