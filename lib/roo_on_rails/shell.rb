require 'bundler'
require 'roo_on_rails/checks'

module RooOnRails
  class Shell
    CommandFailed = Class.new(StandardError)

    def run(cmd)
      result = Bundler.with_clean_env { `#{cmd}` }
      [$CHILD_STATUS.success?, result]
    end

    def run!(cmd)
      raise CommandFailed, cmd unless run(cmd).first
    end

    def run?(cmd)
      run(cmd).first
    end
  end
end
