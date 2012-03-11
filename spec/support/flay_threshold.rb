class FlayThresholdBreached < Exception
  def initialize(flay, max_value, threshold)
    flay.report
    super("Flay total too high! #{max_value} > #{threshold}")
  end
end