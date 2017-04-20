require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'logger'
require 'active_support/logger'

module RooOnRails
  # Wraps any standard logger to provide context, similar to `ActiveSupport::TaggedLogging`
  # but with key/value pairs that are appended to the end of the text.
  #
  #   logger = RooOnRails::ContextLogging.new(Logger.new($stdout))
  #   logger.context(a: 1, b: 2) { logger.info 'foo' }                     # Logs "foo -- a=1 b=2"
  #   logger.context(a: 1) { logger.context(b: 2) { logger.info('foo') } } # Logs "foo -- a=1 b=2"
  #
  # You can also use `push_context` and `pop_context` in before/after blocks.
  #
  #   class ApplicationController < ActionController::Base
  #     before_action { logger.push_context(user_id: current_user.id) }
  #     after_action { logger.pop_context }
  #   end
  module ContextLogging
    module Formatter
      def call(severity, timestamp, progname, msg)
        super(severity, timestamp, progname, "#{msg}#{context_text}")
      end

      def context(**context)
        push_context(**context)
        yield self
      ensure
        pop_context
      end

      def push_context(**context)
        current_context.push(context)
      end

      def pop_context
        current_context.pop
      end

      def clear_context!
        current_context.clear
      end

      def current_context
        # We use our object ID here to avoid conflicting with other instances
        thread_key = @thread_key ||= "roo_on_rails:logging_context:#{object_id}".freeze
        Thread.current[thread_key] ||= []
      end

      private

      def context_text
        context = current_context
        return nil unless context.any?

        merged_context = context.each_with_object({}) { |ctx, acc| acc.merge!(ctx) }
        ' -- ' + merged_context.map { |k, v| "#{k}=#{v}" }.join(' ')
      end
    end

    def self.new(logger)
      # Ensure we set a default formatter so we aren't extending nil!
      logger.formatter ||= ActiveSupport::Logger::SimpleFormatter.new
      logger.formatter.extend(Formatter)
      logger.extend(self)
    end

    delegate :push_context, :pop_context, :clear_context!, to: :formatter

    def context(**context)
      formatter.context(**context) { yield self }
    end

    def flush
      clear_context!
      super if defined?(super)
    end
  end
end
