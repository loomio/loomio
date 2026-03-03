class RemoveCanStartPollsWithoutDiscussionFromGroups < ActiveRecord::Migration[8.0]
  def change
    remove_column :groups, :can_start_polls_without_discussion, :boolean, default: true, null: false
  end
end
