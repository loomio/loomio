class BallotValidator
  attr_reader :poll, :choices, :none_of_the_above

  def initialize(poll:, choices:, none_of_the_above:)
    @poll = poll
    @choices = choices
    @none_of_the_above = none_of_the_above
  end

  # Evaluate a complete ballot as one value. Scalar score bounds alone cannot
  # express invariants such as a dot budget or a unique contiguous ranking, so
  # this returns stable reason codes for both model validation and data audits.
  def reasons
    if none_of_the_above
      result = []
      result << :none_of_the_above_not_allowed unless poll.show_none_of_the_above
      result << :none_of_the_above_with_choices if choices.any?
      return result
    end

    result = []
    scores = choices.map(&:score)
    return [ :score_invalid ] unless scores.all? { |score| score.is_a?(Integer) }

    result << :score_negative if scores.any?(&:negative?)

    choice_count_min = integer_value(poll.minimum_stance_choices)
    choice_count_max = integer_value(poll.maximum_stance_choices)
    score_min = integer_value(poll.min_score)
    score_max = integer_value(poll.max_score)
    unless choice_count_min && choice_count_max &&
           value_is_integer_or_nil?(poll.min_score, score_min) &&
           value_is_integer_or_nil?(poll.max_score, score_max)
      return [ :poll_configuration_invalid ]
    end

    result << :choice_count_below_minimum if choices.length < choice_count_min
    result << :choice_count_above_maximum if choices.length > choice_count_max
    result << :score_below_minimum if score_min && scores.any? { |score| score < score_min }
    result << :score_above_maximum if score_max && scores.any? { |score| score > score_max }

    case poll.ballot_rule
    when "bounded"
      nil
    when "dot_vote"
      dots_per_person = integer_value(poll.dots_per_person)
      return [ :poll_configuration_invalid ] unless dots_per_person

      result << :dots_exceeded if scores.sum > dots_per_person
    when "ranked_points"
      result << :ranked_choice_count_invalid unless choices.length == choice_count_min
      result << :rank_sequence_invalid unless scores.sort == (1..choices.length).to_a
    when "ranked_preferences"
      result << :rank_sequence_invalid unless scores.sort == (1..choices.length).to_a
    when "reason_only"
      result << :choices_not_allowed if choices.any?
    else
      result << :ballot_rule_unknown
    end

    result.uniq
  end


  private

  def integer_value(value)
    Integer(value, exception: false)
  end

  def value_is_integer_or_nil?(value, integer)
    value.nil? || !integer.nil?
  end
end
