require 'thor'
require 'hashie'
require 'roo_on_rails/checks'
require 'roo_on_rails/checks/git/origin'
require 'roo_on_rails/checks/heroku/toolbelt_installed'
require 'roo_on_rails/checks/heroku/toolbelt_working'
require 'roo_on_rails/checks/heroku/login'
require 'roo_on_rails/checks/heroku/token'
require 'roo_on_rails/checks/heroku/app_exists'
require 'roo_on_rails/checks/heroku/preboot_enabled'

module RooOnRails
  class Harness
    include Thor::Shell

    def initialize(try_fix: false)
      @try_fix = try_fix
      @state = Hashie::Mash.new
    end

    def run
      # TODO: use TSort for dependencies between checks
      [
        Checks::Git::Origin,
        Checks::Heroku::ToolbeltInstalled,
        Checks::Heroku::ToolbeltWorking,
        Checks::Heroku::Login,
        Checks::Heroku::Token,
        Checks::Heroku::AppExists::All,
        Checks::Heroku::PrebootEnabled::All,
      ].each do |c|
        c.run(fix: @try_fix, context: @state)
      end
      self
    rescue Checks::CommandFailed
      say 'A command failed to run, aborting', %i[bold red]
      exit 2
    rescue Checks::Failure
      say 'A check failed, exiting', %i[bold red]
      exit 1
    end
  end
end
