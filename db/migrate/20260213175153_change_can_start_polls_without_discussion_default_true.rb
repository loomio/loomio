class ChangeCanStartPollsWithoutDiscussionDefaultTrue < ActiveRecord::Migration[8.0]
  def change
    change_column_default :groups, :can_start_polls_without_discussion, from: false, to: true
  end
end
