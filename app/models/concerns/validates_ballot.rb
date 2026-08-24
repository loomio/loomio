module ValidatesBallot
  extend ActiveSupport::Concern

  included do
    validate :ballot_is_valid
  end

  private

  # Ballot integrity depends on the submitted choices as a set. Validate the
  # effective poll bounds for every poll type, then apply rules such as dot
  # totals and contiguous rankings that cannot be expressed by scalar bounds.
  def ballot_is_valid
    return unless ballot_validation_required?
    return unless poll
    return if none_of_the_above

    choices = ballot_choices_for_validation
    scores = choices.map(&:score)
    unless scores.all? { |score| score.is_a?(Integer) }
      ballot_error_add
      return
    end

    ballot_validate_choice_count(choices.length)
    ballot_validate_score_bounds(scores)

    case poll.ballot_rule
    when "bounded"
      nil
    when "dot_vote"
      ballot_error_add if scores.sum > poll.dots_per_person.to_i
    when "ranked_points"
      ballot_error_add unless choices.length == poll.minimum_stance_choices && scores.sort == (1..choices.length).to_a
    when "ranked_preferences"
      ballot_error_add unless scores.sort == (1..choices.length).to_a
    when "reason_only"
      ballot_error_add if choices.any?
    else
      ballot_error_add
    end
  end

  def ballot_validate_choice_count(choice_count)
    ballot_error_add if choice_count < poll.minimum_stance_choices
    ballot_error_add if choice_count > poll.maximum_stance_choices
  end

  def ballot_validate_score_bounds(scores)
    score_min = poll.min_score
    score_max = poll.max_score
    ballot_error_add if score_min && scores.any? { |score| score < score_min }
    ballot_error_add if score_max && scores.any? { |score| score > score_max }
  end

  def ballot_error_add
    errors.add(ballot_choices_error_attribute, :invalid) unless errors.added?(ballot_choices_error_attribute, :invalid)
  end
end
