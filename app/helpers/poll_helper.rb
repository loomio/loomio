# frozen_string_literal: true

module PollHelper
  def option_name(name, format, zone, date_time_pref)
    case format
    when 'i18n'
      t(name)
    when 'iso8601'
      format_iso8601_for_humans(name, zone, date_time_pref)
    else
      name
    end
  end

  def dot_vote_stance_choice_percentage_for(stance, stance_choice)
    max = stance.poll.dots_per_person.to_i
    if max > 0
      (100 * stance_choice.score.to_f / max).to_i
    else
      0
    end
  end

  def score_stance_choice_percentage_for(stance, stance_choice)
    max = stance.poll.max_score.to_i
    if max > 0
      (100 * stance_choice.score.to_f / max).to_i
    else
      0
    end
  end
end
