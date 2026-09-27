class VoteWeight
  def self.format(value)
    value.to_d.to_s('F').sub(/\.0+\z/, '').sub(/(\.\d*?)0+\z/, '\\1')
  end
end
