class AnonymousBallot < ApplicationRecord
  include ValidatesBallot

  belongs_to :poll
  has_many :anonymous_ballot_choices, dependent: :destroy
  has_many :poll_options, through: :anonymous_ballot_choices
  has_one :legacy_anonymous_vote_reason, dependent: :destroy

  accepts_nested_attributes_for :anonymous_ballot_choices

  before_update { throw(:abort) }
  before_destroy { throw(:abort) }

  validate :poll_uses_detached_anonymous_voting

  private

  def poll_uses_detached_anonymous_voting
    errors.add(:poll, :invalid) unless poll&.detached_anonymous?
  end

  def ballot_validation_required?
    poll.present?
  end

  def ballot_choices_for_validation
    anonymous_ballot_choices
  end

  def ballot_choices_error_attribute
    :anonymous_ballot_choices
  end
end
