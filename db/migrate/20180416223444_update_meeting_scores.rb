class UpdateMeetingScores < ActiveRecord::Migration[5.1]
  def change
    StanceChoice.joins(:poll)
      .where("polls.poll_type": :meeting)
      .where(score: 1)
      .update_all(score: 2)
    Poll.where(poll_type: :meeting).map(&:update_stance_data)
  end
end
