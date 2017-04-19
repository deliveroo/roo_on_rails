require 'dotenv'
module RooOnRails
  class Environment
    def self.load
      Dotenv.load
      Dotenv.load File.expand_path('../default.env', __FILE__)
    end
  end
end
