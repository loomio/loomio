class PollOptionSerializer < ApplicationSerializer
  attributes :name, :id, :poll_id, :priority, :voter_scores, :color, :total_score

  def voter_scores
    if ENV['JIT_POLL_COUNTS'] &&
       object.voter_scores == {} &&
       (poll.stance_counts.length == 0 ||
        !poll.stance_counts[object.priority] ||
        poll.stance_counts[object.priority] > 0)
      poll.update_counts!
    end
    object.voter_scores
  end

  def include_total_score?
    poll.show_results?
  end

  def include_voter_scores?
    !poll.anonymous? && poll.show_results?(voted: current_user_voted)
  end

  def current_user_voted
    stance = cache_fetch(:stances_by_poll_id, object.poll_id) { nil }
    !!(stance && stance.cast_at)
  end
end
