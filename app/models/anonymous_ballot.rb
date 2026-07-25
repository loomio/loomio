class AnonymousBallot < ApplicationRecord
  belongs_to :poll
  has_many :anonymous_ballot_choices, dependent: :destroy
  has_many :poll_options, through: :anonymous_ballot_choices

  accepts_nested_attributes_for :anonymous_ballot_choices

  before_update { throw(:abort) }
  before_destroy { throw(:abort) }

  validate :poll_uses_detached_anonymous_voting
  validate :poll_options_match_poll
  validate :poll_options_are_unique
  validate :choice_count_is_valid
  validate :scores_are_valid
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

  def choice_count_is_valid
    return unless poll
    return if none_of_the_above

    count = anonymous_ballot_choices.length
    errors.add(:anonymous_ballot_choices, :too_few) if count < poll.minimum_stance_choices
    errors.add(:anonymous_ballot_choices, :too_many) if count > poll.maximum_stance_choices
  end

  def scores_are_valid
    return unless poll

    scores = anonymous_ballot_choices.map(&:score)
    unless scores.all? { |score| score.is_a?(Integer) }
      errors.add(:anonymous_ballot_choices, :invalid)
      return
    end

    score_min = poll.min_score || -Float::INFINITY
    score_max = poll.max_score || Float::INFINITY
    errors.add(:anonymous_ballot_choices, :invalid) if scores.any? { |score| score < score_min || score > score_max }
    if poll.vote_method == "dot_vote" && scores.sum > poll.dots_per_person
      errors.add(:anonymous_ballot_choices, :invalid)
    end
    if poll.require_all_choices && anonymous_ballot_choices.length != poll.poll_options.length
      errors.add(:anonymous_ballot_choices, :invalid)
    end
  end

  def none_of_the_above_is_valid
    return unless none_of_the_above

    errors.add(:none_of_the_above, :invalid) unless poll&.show_none_of_the_above
    errors.add(:anonymous_ballot_choices, :invalid) if anonymous_ballot_choices.any?
  end
end
