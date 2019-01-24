require 'dotenv'
require 'envied'
module RooOnRails
  class Environment
    def self.load
      # variables from the :hopper group MUST be specified in Hopper, so cannot be loaded from dotenv file
      if envfile_present? && hopper_environment?
        ENVied.require(:hopper)
      end

      Dotenv.load
      Dotenv.load File.expand_path('../default.env', __FILE__)
      ENVied.require if envfile_present?
    end

    private
    def self.envfile_present?
      FileTest.exist?(Rails.root.join('Envfile'))
    end

    def self.hopper_environment?
      !(Rails.env.development? || Rails.env.test?)
    end
  end
end
