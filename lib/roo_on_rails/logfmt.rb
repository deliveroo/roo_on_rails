module RooOnRails
  # A generator for the logfmt log format.
  #
  # @see https://brandur.org/logfmt The original description of logfmt
  # @see https://godoc.org/github.com/kr/logfmt The 'reference' parser
  module Logfmt
    class << self
      SPACE = 0x20
      QUOTE = 0x22
      EQUALS = 0x3d

      def dump(hash)
        return nil if hash.nil? || hash.empty?

        hash.map { |k, v| "#{k}=#{dump_value(v)}" }.join(' ')
      end

      private

      def dump_value(v)
        str = case v
              when String then v
              when Symbol then v.to_s
              else v.respond_to?(:to_json) ? v.to_json : v.inspect
              end
        escape(str)
      end

      def escape(str)
        return str if ident?(str)

        escaped = str.gsub(/(["\\])/, '\\\\\1')
        %("#{escaped}")
      end

      def ident?(str)
        str.bytes.all? { |b| b > SPACE && b != EQUALS && b != QUOTE }
      end
    end
  end
end
