class AnonymousBallotChoice < ApplicationRecord
  belongs_to :anonymous_ballot
  belongs_to :poll_option

  validates :poll_option_id, uniqueness: { scope: :anonymous_ballot_id }
  validates :score, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  before_update { throw(:abort) }
  before_destroy { throw(:abort) }
end
