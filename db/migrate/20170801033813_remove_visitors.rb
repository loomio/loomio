class RemoveVisitors < ActiveRecord::Migration
  def change
    drop_table :visitors
    remove_column :polls, :visitors_count
    drop_column :stances, :participant_type
    remove_index :stances, :index_stances_on_participant_id_and_participant_type
    add_index :stances, :participant_id
  end
end
