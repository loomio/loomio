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
  validate :poll_options_match_poll
  validate :poll_options_are_unique
  validate :none_of_the_above_is_valid

  private

  def poll_uses_detached_anonymous_voting
    errors.add(:poll, :invalid) unless poll&.detached_anonymous?
  end

  def poll_options_match_poll
    return unless poll

    unless anonymous_ballot_choices.all? { |choice| choice.poll_option&.poll_id == poll_id }
      errors.add(:anonymous_ballot_choices, :invalid)
    end
  end

  def poll_options_are_unique
    option_ids = anonymous_ballot_choices.map(&:poll_option_id)
    errors.add(:anonymous_ballot_choices, :invalid) unless option_ids.compact.uniq.length == option_ids.length
  end

  def none_of_the_above_is_valid
    return unless none_of_the_above

    errors.add(:none_of_the_above, :invalid) unless poll&.show_none_of_the_above
    errors.add(:anonymous_ballot_choices, :invalid) if anonymous_ballot_choices.any?
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
