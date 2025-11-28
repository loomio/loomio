class AlterCanStartPollsWithoutDiscussionsDefaultFalse < ActiveRecord::Migration[7.2]
  def change
    change_column :groups, :can_start_polls_without_discussion, :boolean, default: false, null: false
  end
end
