require 'json'

module RooOnRails
  # A generator for the logfmt log format.
  #
  # @see https://brandur.org/logfmt The original description of logfmt
  # @see https://godoc.org/github.com/kr/logfmt The 'reference' parser
  module Logfmt
    class << self
      def dump(hash)
        return nil if hash.nil? || hash.empty?

        hash.map { |k, v| "#{k}=#{dump_value(v)}" }.join(' ')
      end

      private

      def dump_value(v)
        str = case v
              when String then v
              when Symbol then v.to_s
              when Array, Hash then JSON.dump(v)
              else v.respond_to?(:to_json) ? v.to_json : v.inspect
              end

        @_escape_re ||= /[[:space:]"']/
        return str unless @_escape_re =~ str
        str.inspect
      end
    end
  end
end
