require 'roo_on_rails/shell'

class FakeShell < RooOnRails::Shell
  def initialize
    @stubs = Hash.new { |h,k| h[k] = [] }
  end

  def stub(cmd, success: true, output: '')
    @stubs[cmd] << [success, output]
  end

  def run(cmd)
    success, output = @stubs[cmd].pop
    raise "missing stub for '#{cmd}'" if success.nil?
    return [success, output]
  end
end
