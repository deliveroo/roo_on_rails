require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'logger'
require 'active_support/logger'
require 'roo_on_rails/logfmt'

module RooOnRails
  # Wraps any standard logger to provide context, similar to `ActiveSupport::TaggedLogging`
  # but with key/value pairs that are appended to the end of the text.
  #
  #   logger = RooOnRails::ContextLogging.new(Logger.new($stdout))
  #   logger.with(a: 1, b: 2) { logger.info 'Stuff' }                   # Logs "Stuff -- a=1 b=2"
  #   logger.with(a: 1) { logger.with(b: 2) { logger.info('Stuff') } }  # Logs "Stuff -- a=1 b=2"
  #
  # The above methods persist the context in thread local storage so it will be attached to
  # any logs made within the scope of the block, even in called methods. However, if your
  # context only applies to the current log then you can chain off the `with` method.
  #
  #   logger.with(a: 1, b: 2).info('Stuff')                   # Logs "Stuff -- a=1 b=2"
  #   logger.with(a: 1) { logger.with(b: 2).info('Stuff')  }  # Logs "Stuff -- a=1 b=2"
  module ContextLogging
    module Formatter
      def call(severity, timestamp, progname, msg)
        super(severity, timestamp, progname, "#{msg}#{context_text}")
      end

      def with(**context)
        current_context.push(context)
        yield self
      ensure
        current_context.pop
      end

      def clear_context!
        current_context.clear
      end

      private

      def current_context
        # We use our object ID here to avoid conflicting with other instances
        thread_key = @thread_key ||= "roo_on_rails:logging_context:#{object_id}".freeze
        Thread.current[thread_key] ||= []
      end

      def context_text
        context = current_context
        return nil if context.empty?

        merged_context = context.each_with_object({}) { |ctx, acc| acc.merge!(ctx) }
        ' ' + Logfmt.dump(merged_context)
      end
    end

    class LoggerProxy
      def initialize(logger, context)
        @logger = logger
        @context = context
      end

      %i[debug info warn error fatal unknown].each do |severity|
        define_method severity do |message|
          @logger.with(**@context) { @logger.public_send(severity, message) }
        end
      end
    end

    def self.new(logger)
      # Ensure we set a default formatter so we aren't extending nil!
      logger.formatter ||= ActiveSupport::Logger::SimpleFormatter.new
      logger.formatter.extend(Formatter)
      logger.extend(self)
    end

    delegate :clear_context!, to: :formatter

    def with(**context)
      if block_given?
        formatter.with(**context) { yield self }
      else
        LoggerProxy.new(self, context)
      end
    end

    def flush
      clear_context!
      super if defined?(super)
    end
  end
end
