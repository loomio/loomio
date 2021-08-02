class PollOptionSerializer < ApplicationSerializer
  attributes :name, :id, :poll_id, :priority, :voter_scores, :color, :total_score

  def color
    AppConfig.colors.dig(poll.poll_type, object.priority % AppConfig.colors.length)
  end

  def include_total_score?
    poll.show_results?
  end

  def include_voter_scores?
    poll.show_results?
  end
end
