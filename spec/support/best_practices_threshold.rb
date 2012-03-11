class BestPracticesBreached < Exception
  def initialize(analyzer, threshold)
    analyzer.output
    super("Best practices breached! #{analyzer.runner.errors.length} > #{threshold}")
  end
end