require 'thor'
require 'hashie'
require 'roo_on_rails/checks/environment'
require 'roo_on_rails/environment'

module RooOnRails
  class Harness
    include Thor::Shell

    def initialize(try_fix: false, context: nil)
      @try_fix = try_fix
      @context = context || Hashie::Mash.new
    end

    def run
      [
        Checks::Environment.new(env: 'staging',    fix: @try_fix, context: @context),
        Checks::Environment.new(env: 'production', fix: @try_fix, context: @context),
      ].each(&:run)
      self
    rescue Shell::CommandFailed
      say 'A command failed to run, aborting', %i[bold red]
      exit 2
    rescue Checks::Failure
      say 'A check failed, exiting', %i[bold red]
      exit 1
    end
  end
end
