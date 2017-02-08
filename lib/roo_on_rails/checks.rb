module RooOnRails
  module Checks
    CommandFailed = Class.new(StandardError)
    Failure = Class.new(StandardError)
    FinalFailure = Class.new(Failure)
  end
end

