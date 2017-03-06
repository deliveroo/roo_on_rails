require 'spec_helper'
require 'timeout'


# turn this on to get verbose tests
VERBOSE = ENV.fetch('VERBOSE_ACCEPTANCE_TESTS', 'NO') == 'YES'

module ROR
  class SubProcess
    attr_reader :status

    def initialize(name:, dir: nil, command:, start: nil, stop: nil)
      @name    = name
      @dir     = dir
      @command = command
      @pid     = nil
      @reader  = nil
      @loglines = []
      @start_regexp = start
      @stop_regexp  = stop
      @status = nil
    end

    def start
      raise 'already started' if @pid
      _log 'starting'
      @loglines = []
      @status = nil
      rd, wr = IO.pipe
      if @pid = fork
        # parent
        wr.close
        @reader = Thread.new { _read_log(rd) }
      else
        _log "forked (##{$$})"
        # child
        rd.close
        $stdin.reopen('/dev/null')
        $stdout.reopen(wr)
        $stderr.reopen(wr)
        $stdout.sync = true
        $stderr.sync = true
        Dir.chdir @dir.to_s if @dir

        Bundler.with_original_env do
          # this is required on Travis as it sets BUNDLE_GEMFILE explicitly:
          ENV.delete('BUNDLE_GEMFILE')
          exec @command
        end
      end
      self
    end

    # politely ask the process to stop, and wait for it to exit
    def stop
      return self if @pid.nil?
      _log "stopping (##{@pid})"
      Process.kill('TERM', @pid)

      Timeout::timeout(10) do
        sleep(10e-3) until Process.wait(@pid, Process::WNOHANG)
        @status = $?
      end

      @pid = nil
      self
    end

    # after calling `start`, wait until the process has logged a line indicating
    # it is ready for use
    def wait_start
      return self unless @start_regexp && @pid
      _log 'waiting for startup marker'
      wait_log @start_regexp
      _log "started (##{@pid})"
      self
    end

    # after calling `stop`, wait until the log exhibits an entry indicating
    # the process has stoped cleanly
    def wait_stop
      return self unless @stop_regexp && @pid
      _log "waiting for stop marker"
      wait_log @stop_regexp
      _log 'stopped'
      self
    end

    # terminate the process without waiting for logs
    def terminate
      if @pid
        Process.kill('KILL', @pid)
        _log 'wait after SIGKILL'
        Process.wait(@pid)
      end
      @reader.join if @reader
      @pid = @reader = nil
      self
    end

    # wait until a log line is seen that matches `regexp`, up to a timeout
    def wait_log(regexp)
      cursor = 0
      Timeout::timeout(10) do
        loop do
          line = @loglines[cursor]
          sleep(10e-3) if line.nil?
          break if line && line =~ regexp
          cursor += 1 unless line.nil?
        end
      end
      self
    end

    def has_log?(regexp)
      @loglines.any? { |line| line =~ regexp }
    end

    private

    def _read_log(io)
      while line = io.gets
        if VERBOSE
          $stderr.write "\t->> #{line}"
          $stderr.flush
        end
        @loglines.push line
      end
    end

    def _log(message)
      return unless VERBOSE
      $stderr.write("\t-> #{@name}: #{message}\n")
    end
  end
end

