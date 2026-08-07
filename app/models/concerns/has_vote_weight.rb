module HasVoteWeight
  extend ActiveSupport::Concern

  WEIGHT_MAX = 1_000_000

  included do
    validates :weight,
              numericality: {
                only_integer: true,
                greater_than_or_equal_to: 0,
                less_than_or_equal_to: WEIGHT_MAX
              }
  end
end
