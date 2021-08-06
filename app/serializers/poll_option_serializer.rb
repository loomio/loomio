class PollOptionSerializer < ApplicationSerializer
  attributes :name, :id, :poll_id, :priority, :voter_scores, :color, :total_score

  def color
    AppConfig.colors.dig(poll.poll_type, object.priority % AppConfig.colors.length)
  end

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
    poll.show_results?
  end
end
