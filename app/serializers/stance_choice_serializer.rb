class StanceChoiceSerializer < ApplicationSerializer
  attributes :id, :score, :created_at, :stance_id, :rank, :rank_or_score, :poll_option_id

  def stance
    cache_fetch(:stances_by_id, object.stance_id) { object.stance }
  end

  def poll
    cache_fetch(:polls_by_id, cache_fetch(:stances_by_id, object.stance_id).poll_id) { object.poll }
  end

  def rank
    poll.minimum_stance_choices - object.score + 1 if poll.poll_type == 'ranked_choice'
  end

  def rank_or_score
    rank || object.score
  end
end
