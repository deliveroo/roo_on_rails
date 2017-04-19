require 'forwardable'
require 'singleton'
require 'thor'

module RooOnRails
  module Checks
    module Helpers
      class Receiver < Thor::Group
        include Singleton
        include Thor::Actions
      end

      def self.included(by)
        by.class_eval do
          extend Forwardable
          delegate %i(say ask yes? no? create_file
                      add_file remove_file copy_file
                      template directory inside inject_into_file
                      append_to_file) => :'RooOnRails::Checks::Helpers::Receiver.instance'
        end
      end

      def bold(str)
        "\e[1;4m#{str}\e[22;24m"
      end
    end
  end
end
