class Measurement
  def increment(name)
    Librarto.increment(name)
  end

  def measure(name, amount)
    Librarto.measure(name, amount)
  end

  def timing(name, &block)
    Librarto.timing(name, block)
  end
end
