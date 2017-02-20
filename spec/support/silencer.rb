module Kernel
  module_function

  # Taken from Rails 4. Not thread safe.
  # File activesupport/lib/active_support/core_ext/kernel/reporting.rb, line 41
  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen '/dev/null'
    stream.sync = true
    yield
  ensure
    stream.reopen(old_stream)
  end
end
