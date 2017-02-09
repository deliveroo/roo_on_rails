require 'roo_on_rails/checks'
require 'roo_on_rails/checks/helpers'

module RooOnRails
  module Checks
    class Base
      include Helpers

      def self.run(**options)
        new(**options).run
      end

      def initialize(fix: false, context: nil)
        @fix = fix
        @context = context
      end

      def run
        say _intro
        call
      rescue Failure
        raise unless @fix
        say "\t· attempting to fix", %i[yellow]
        fix
        say "\t· re-checking", %i[yellow]
        call
      end

      protected

      def _intro
        self.class.name
      end

      def call
        fail! "this check wasn't implemented"
      end

      def fix
        fail! "can't fix this on my own"
      end

      def context
        @context
      end

      def shell(cmd)
        result = Bundler.with_clean_env { %x{#{cmd}} }
        return [$?.success?, result]
      end

      def shell!(cmd)
        Bundler.with_clean_env { system(cmd) }
        raise CommandFailed.new(cmd) unless $?.success?
      end

      def shell?(cmd)
        Bundler.with_clean_env { system(cmd) }
        $?.success?
      end

      def pass(msg)
        say "\t✔ #{msg}", :green
      end

      def fail!(msg)
        say "\t✘ #{msg}", :red
        raise Failure
      end
    end
  end
end
