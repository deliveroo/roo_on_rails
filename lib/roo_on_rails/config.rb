require 'hashie'
require 'pathname'

module RooOnRails
  class Config < Hashie::Mash
    class << self
      def load
        path = Pathname '.roo_on_rails.yml'
        path.exist? ? super(path) : new
      end
    end
  end
end
