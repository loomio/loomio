require 'stringio'

module Kernel
  def capture_stdout
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end
end

class FlayThresholdBreached < Exception
  def initialize(flay, max_value, threshold)
    out = capture_stdout do
      flay.report
    end
    super("Flay total too high! #{max_value} > #{threshold}\n#{out.string}")
  end
end