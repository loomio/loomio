class AddIndexGroupIdToPolls < ActiveRecord::Migration
  def change
    add_index :polls, :group_id
  end
end
