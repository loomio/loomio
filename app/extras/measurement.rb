class Measurement
  def self.increment(name)
    Librato.increment(prefix name)
  end

  def self.measure(name, amount)
    Librato.measure(prefix(name), amount)
  end

  def self.prefix(name)
    "loomio.#{name}"
  end
end
