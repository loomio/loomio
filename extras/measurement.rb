class Measurement
  def self.increment(name)
    Librato.increment(name)
  end

  def self.measure(name, amount)
    Librato.measure(name, amount)
  end
end
