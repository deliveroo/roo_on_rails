require 'thor'
require 'hashie'
require 'roo_on_rails/checks/environment'
require 'roo_on_rails/environment'
require 'roo_on_rails/checks/environment_independent'

module RooOnRails
  class Harness
    include Thor::Shell

    def initialize(try_fix: false, environments: nil, context: Hashie::Mash.new, dry_run: false)
      @try_fix = try_fix
      @context = context
      @dry_run = dry_run
      @environments = environments
    end

    def run
      checks = [
        Checks::EnvironmentIndependent.new(fix: @try_fix, context: @context, dry_run: @dry_run),
      ]
      environments.each do |env|
        checks << Checks::Environment.new(env: env.strip, fix: @try_fix, context: @context, dry_run: @dry_run)
      end

      return if checks.map(&:run).all?
      say 'At least one check failed.', %i[bold red]
    end

    private

    def environments
      as_string = @environments || ENV.fetch('ROO_ON_RAILS_ENVIRONMENTS', 'staging,production')
      as_string.split(',')
    end
  end
end
