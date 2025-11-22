class AddCanStartPollsWithoutDiscussionsToGroup < ActiveRecord::Migration[7.2]
  def change
    add_column :groups, :can_start_polls_without_discussion, :boolean, default: true, null: false
  end
end
