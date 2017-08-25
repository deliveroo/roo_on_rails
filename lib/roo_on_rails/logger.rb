require 'logger'
require 'delegate'
require 'roo_on_rails/logfmt'

module RooOnRails
  # A compatible replacement for the standard Logger to provide context, similar to `ActiveSupport::TaggedLogging`
  # but with key/value pairs in logfmt format.
  #
  #   logger = RooOnRails::Logger.new(STDOUT)
  #   logger.with(a: 1, b: 2) { logger.info 'Stuff' }                   # Logs "at=INFO msg=Stuff a=1 b=2"
  #   logger.with(a: 1) { logger.with(b: 2) { logger.info('Stuff') } }  # Logs "at=INFO msg=Stuff a=1 b=2"
  #
  # The above methods persist the context in thread local storage so it will be attached to
  # any logs made within the scope of the block, even in called methods. However, if your
  # context only applies to the current log then you can chain off the `with` method.
  #
  #   logger.with(a: 1, b: 2).info('Stuff')                   # Logs "at=INFO msg=Stuff a=1 b=2"
  #   logger.with(a: 1) { logger.with(b: 2).info('Stuff')  }  # Logs "at=INFO msg=Stuff a=1 b=2"
  #
  # Hashes, arrays and any complex object that supports `#to_json` will be output in escaped
  # JSON format so that it can be parsed out of the attribute values.
  class Logger < SimpleDelegator
    def initialize(io = STDOUT)
      @show_timestamp = io.tty?
      logger = ::Logger.new(io).tap do |l|
        l.formatter = method(:_formatter)
      end
      super(logger)
      set_log_level
    end

    def with(context = {})
      unless block_given?
        return Proxy.new(self, context)
      end

      new_context = (_context_stack.last || {}).merge(context)
      Thread.handle_interrupt(Exception => :never) do
        begin
          _context_stack.push(new_context)
          Thread.handle_interrupt(Exception => :immediate) do
            yield self
          end
        ensure
          _context_stack.pop
        end
      end
      nil
    end

    def clear_context!
      _context_stack.replace([{}])
    end

    def set_log_level
      self.level = ::Logger::Severity.const_get(ENV.fetch('LOG_LEVEL', 'DEBUG'))
    end

    private

    class Proxy < SimpleDelegator
      def initialize(logger, context)
        @context = context
        super(logger)
      end

      %w[add debug info warn error fatal unknown].each do |name|
        define_method name do |*args, &block|
          __getobj__.with(@context) do
            __getobj__.public_send(name, *args, &block)
          end
        end
      end
    end

    TIMESTAMP_FORMAT = '%F %T.%L'

    def _formatter(severity, datetime, _progname, message)
      if @show_timestamp
        "[%s] %7s | %s %s\n" % [
          datetime.utc.strftime(TIMESTAMP_FORMAT),
          severity,
          message,
          Logfmt.dump(_context_stack.last)
        ]
      else
        "%s\n" % Logfmt.dump({
          at:   severity,
          msg:  message
        }.merge(_context_stack.last))
      end
    end

    def _context_stack
      # We use our object ID here to avoid conflicting with other instances
      thread_key = @_context_stack_key ||= "roo_on_rails:logging_context:#{object_id}".freeze
      Thread.current[thread_key] ||= [{}]
    end

    def context_text
      context = current_context
      return nil if context.empty?

      merged_context = context.each_with_object({}) { |ctx, acc| acc.merge!(ctx) }
      ' ' + Logfmt.dump(merged_context)
    end
  end
end
