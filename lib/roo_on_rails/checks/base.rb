require 'roo_on_rails/checks'
require 'roo_on_rails/checks/helpers'
require 'roo_on_rails/shell'
require 'bundler'

module RooOnRails
  module Checks
    class Base
      include Helpers

      # Add `dependencies` to the list of prerequisites for this check.
      # If none are specified, return the list of dependencies.
      def self.requires(*dependencies)
        @requires ||= Set.new
        dependencies.any? ? @requires.merge(dependencies) : @requires
      end

      def initialize(options = {})
        @options = options.dup
        @fix     = @options.delete(:fix) { false }
        @context = @options.delete(:context) { Hashie::Mash.new }
        @shell   = @options.delete(:shell) { Shell.new }
        @dry_run = options.fetch(:dry_run, false)
      end

      def run
        dependency_status = resolve dependencies

        say intro
        unless dependency_status
          final_fail! 'Unmet dependencies.'
          return
        end

        return true if @dry_run

        begin
          call
        rescue Failure => e
          return false unless @fix
          say "\t· attempting to fix", %i[yellow]
          fix
          @fix = false
          say "\t· re-checking", %i[yellow]
          retry
        end

        true
      rescue FinalFailure
        false
      end

      protected

      attr_reader :shell, :context, :options

      # Returns prerequisite checks. Can be overriden.
      def dependencies
        @dependencies ||= self.class.requires.map { |k|
          k.new(fix: @fix, context: @context, shell: @shell, **@options)
        }
      end

      def intro
        self.class.name
      end

      def call
        final_fail! "this check wasn't implemented"
      end

      def fix
        final_fail! "can't fix this on my own"
      end

      def pass(msg)
        say "\t✔ #{msg}", :green
      end

      def fail!(msg)
        say "\t✘ #{msg}", :red
        raise Failure, msg
      end

      def final_fail!(msg)
        say "\t✘ #{msg}", :red
        raise FinalFailure, msg
      end

      # Return a unique signature for this check
      def signature
        [self.class.name]
      end

      private

      # Run each dependency, then mark them as run.
      def resolve(deps)
        context.deps ||= {}
        deps.map { |dep|
          sig = dep.signature.join('/')
          if context.deps.has_key?(sig)
            context.deps[sig]
          else
            context.deps[sig] = dep.run
          end
        }.to_a.all?
      end
    end
  end
end
