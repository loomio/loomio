class VoteWeight
  class Invalid < StandardError; end

  # Matches the client's voteWeightValid. Weights are stored as numeric(12,3),
  # so extra decimal places are rounded, as the user manual describes.
  PATTERN = /\A(?:0|[1-9]\d{0,8})(?:\.\d+)?\z/
  MAX = BigDecimal('999999999.999')

  def self.parse!(value)
    text = value.to_s.strip
    raise Invalid, "invalid vote weight: #{value.inspect}" unless PATTERN.match?(text)

    weight = BigDecimal(text).round(3)
    raise Invalid, "vote weight too large: #{value.inspect}" if weight > MAX

    weight
  end

  def self.format(value)
    value.to_d.to_s('F').sub(/\.0+\z/, '').sub(/(\.\d*?)0+\z/, '\\1')
  end
end
