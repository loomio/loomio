class FlayThresholdChecker
  def initialize
  end

  def check(threshold)
    output = `bundle exec flay lib app`

    result = output.match(/Total score \(lower is better\) = ([0-9]*)/)
    if result
      score = result[1].to_i
      raise FlayThresholdBreached.new(output, score, threshold) if score > threshold
    end
  end
end

class FlayThresholdBreached < Exception
  def initialize(output, score, threshold)
    super("Flay total too high! #{score} > #{threshold}: #{output}")
  end
end