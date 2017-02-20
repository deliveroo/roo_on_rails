module RooOnRails
  module Checks
    Failure = Class.new(StandardError)
    FinalFailure = Class.new(Failure)
  end
end

