module HasVoteWeight
  extend ActiveSupport::Concern

  WEIGHT_MAX = 1_000_000

  def self.format(value)
    value.to_d.to_s('F').sub(/\.0+\z/, '').sub(/(\.\d*?)0+\z/, '\\1')
  end

  included do
    validates :weight,
              numericality: {
                greater_than_or_equal_to: 0,
                less_than_or_equal_to: WEIGHT_MAX
              }
    validate :weight_has_supported_precision
  end

  private

  # The decimal column rounds values on assignment, so check the original input
  # before a more precise weight can silently change the tally.
  def weight_has_supported_precision
    original = read_attribute_before_type_cast(:weight)
    return if original.nil?

    decimal = BigDecimal(original.to_s)
    errors.add(:weight, :invalid) unless (decimal * 1_000).frac.zero?
  rescue ArgumentError
    errors.add(:weight, :invalid)
  end
end
