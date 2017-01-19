require 'spec_helper'

# turn this on to get verbose tests
VERBOSE = ENV.fetch('VERBOSE_ACCEPTANCE_TESTS', 'NO') == 'YES'

module ROR
  class SubProcess
    def initialize(name:, dir: nil, command:, start: nil, stop: nil)
      @name    = name
      @dir     = dir
      @command = command
      @pid     = nil
      @reader  = nil
      @loglines = []
      @start_regexp = start
      @stop_regexp  = stop
    end

    def start
      raise 'already started' if @pid
      _log 'starting'
      @loglines = []
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
        Bundler.with_clean_env { exec @command }
      end
      self
    end

    # politely ask the process to stop
    def stop
      return self if @pid.nil?
      _log "stopping (##{@pid})"
      Process.kill('TERM', @pid)
      self
    end

    # after calling `start`, wait until the process has logged a line indicating
    # it is ready for use
    def wait_start
      return self unless @start_regexp && @pid
      _log 'waiting to start'
      wait_log @start_regexp
      _log "started (##{@pid})"
      self
    end

    # after calling `stop`, wait until the log exhibits an entry indicating
    # the process has stoped cleanly
    def wait_stop
      return self unless @stop_regexp && @pid
      _log "waiting to stop (##{@pid})"
      wait_log @stop_regexp
      _log 'stopped'
    ensure
      terminate
    end

    # terminate the process without waiting
    def terminate
      if @pid
        Process.kill('KILL', @pid)
        _log 'wait after SIGKILL'
        Process.wait(@pid, Process::WNOHANG)
      end
      @reader.join if @reader
      @pid = @reader = nil
      self
    end

    # wait until a log line is seen that matches `regexp`, up to a timeout
    def wait_log(regexp)
      Timeout::timeout(10) do
        loop do
          line = @loglines.shift
          sleep(10e-3) if line.nil?
          break if line && line =~ regexp
        end
      end
      self
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

