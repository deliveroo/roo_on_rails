require 'roo_on_rails/checks'
require 'roo_on_rails/checks/helpers'
require 'roo_on_rails/shell'
require 'bundler'

module RooOnRails
  module Checks
    class Base
      include Helpers

      def self.run(**options)
        new(**options).run
      end

      def initialize(fix: false, context: nil, shell: nil)
        @fix = fix
        @context = context
        @shell = shell || Shell.new
      end

      def run
        say intro
        call
      rescue Failure => e
        raise if e === FinalFailure
        raise unless @fix
        say "\t· attempting to fix", %i[yellow]
        fix
        say "\t· re-checking", %i[yellow]
        call
      end

      protected

      attr_reader :shell, :context

      def intro
        self.class.name
      end

      def call
        fail! "this check wasn't implemented"
      end

      def fix
        fail! "can't fix this on my own"
      end

      def pass(msg)
        say "\t✔ #{msg}", :green
      end

      def fail!(msg)
        say "\t✘ #{msg}", :red
        raise Failure, msg
      end

      def fail‼︎(msg)
        say "\t✘ #{msg}", :red
        raise FinalFailure, msg
      end
    end
  end
end
