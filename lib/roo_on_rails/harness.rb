require 'thor'
require 'hashie'
require 'roo_on_rails/checks/environment'
require 'roo_on_rails/environment'
require 'roo_on_rails/checks/sidekiq/settings'
require 'roo_on_rails/checks/documentation/playbook'

module RooOnRails
  class Harness
    include Thor::Shell

    def initialize(try_fix: false, context: Hashie::Mash.new, dry_run: false)
      @try_fix = try_fix
      @context = context
      @dry_run = dry_run
    end

    def run
      checks = [
        Checks::Sidekiq::Settings.new(fix: @try_fix, context: @context, dry_run: @dry_run),
        Checks::Documentation::Playbook.new(fix: @try_fix, context: @context, dry_run: @dry_run),
      ]
      environments.each do |env|
        checks << Checks::Environment.new(env: env.strip, fix: @try_fix, context: @context, dry_run: @dry_run)
      end

      checks.each(&:run)
      self
    rescue Shell::CommandFailed
      say 'A command failed to run, aborting', %i[bold red]
      exit 2
    rescue Checks::Failure
      say 'A check failed, exiting', %i[bold red]
      exit 1
    end

    private

    def environments
      ENV.fetch('ROO_ON_RAILS_ENVIRONMENTS', 'staging,production').split(',')
    end
  end
end
