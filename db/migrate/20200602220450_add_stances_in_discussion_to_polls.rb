class AddStancesInDiscussionToPolls < ActiveRecord::Migration[5.2]
  def change
    add_column :polls, :stances_in_discussion, :boolean, default: true, null: false
  end
end
