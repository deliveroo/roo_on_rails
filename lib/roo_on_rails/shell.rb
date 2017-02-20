require 'bundler'
require 'roo_on_rails/checks'

module RooOnRails
  class Shell
    CommandFailed = Class.new(StandardError)

    def run(cmd)
      result = Bundler.with_clean_env { %x{#{cmd}} }
      return [$?.success?, result]
    end

    def run!(cmd)
      raise CommandFailed.new(cmd) unless run(cmd).first
    end

    def run?(cmd)
      run(cmd).first
    end
  end
end
