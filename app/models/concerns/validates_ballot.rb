module ValidatesBallot
  extend ActiveSupport::Concern

  included do
    validate :ballot_is_valid
    validate :ballot_poll_options_are_valid
    validate :ballot_none_of_the_above_is_valid
  end

  private

  # Ballot integrity depends on the submitted choices as a set. Validate the
  # effective poll bounds for every poll type, then apply rules such as dot
  # totals and contiguous rankings that cannot be expressed by scalar bounds.
  def ballot_is_valid
    return unless ballot_validation_required?
    return unless poll

    ballot_error_add if ballot_policy_invalid?
  end

  def ballot_error_add
    errors.add(ballot_choices_error_attribute, :invalid) unless errors.added?(ballot_choices_error_attribute, :invalid)
  end

  def ballot_poll_options_are_valid
    return unless poll

    choices = ballot_choices_for_validation
    options = choices.map(&:poll_option)
    option_keys = options.map { |option| option&.id || option&.object_id }
    ballot_error_add if option_keys.compact.uniq.length != option_keys.length
    ballot_error_add if options.any? { |option| option.nil? || option.poll != poll }
  end

  def ballot_none_of_the_above_is_valid
    return unless ballot_validation_required? && none_of_the_above

    errors.add(:none_of_the_above, :invalid) unless poll&.show_none_of_the_above
    ballot_error_add if ballot_choices_for_validation.any?
  end

  # Evaluate the complete configured ballot policy. Scalar score bounds alone
  # cannot express invariants such as a dot budget or a unique contiguous
  # ranking, so this check operates on the submitted choices as one value.
  def ballot_policy_invalid?
    return false if none_of_the_above

    choices = ballot_choices_for_validation
    scores = choices.map(&:score)
    return true unless scores.all? { |score| score.is_a?(Integer) }
    return true if scores.any?(&:negative?)

    choice_count_min = ballot_integer(poll.minimum_stance_choices)
    choice_count_max = ballot_integer(poll.maximum_stance_choices)
    score_min = ballot_integer(poll.min_score)
    score_max = ballot_integer(poll.max_score)
    return true unless choice_count_min && choice_count_max
    return true unless ballot_integer_or_nil?(poll.min_score, score_min)
    return true unless ballot_integer_or_nil?(poll.max_score, score_max)
    return true if choices.length < choice_count_min || choices.length > choice_count_max
    return true if score_min && scores.any? { |score| score < score_min }
    return true if score_max && scores.any? { |score| score > score_max }

    case poll.ballot_rule
    when "bounded"
      false
    when "dot_vote"
      dots_per_person = ballot_integer(poll.dots_per_person)
      dots_per_person.nil? || scores.sum > dots_per_person
    when "ranked_points"
      choices.length != choice_count_min || !ballot_rank_sequence_valid?(scores)
    when "ranked_preferences"
      !ballot_rank_sequence_valid?(scores)
    when "reason_only"
      choices.any?
    else
      true
    end
  end

  def ballot_rank_sequence_valid?(scores)
    scores.sort == (1..scores.length).to_a
  end

  def ballot_integer(value)
    Integer(value, exception: false)
  end

  def ballot_integer_or_nil?(value, integer)
    value.nil? || !integer.nil?
  end
end
