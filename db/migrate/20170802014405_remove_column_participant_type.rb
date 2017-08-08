class RemoveColumnParticipantType < ActiveRecord::Migration
  def change
    remove_column :stances, :participant_type
    add_index :stances, :participant_id
  end
end
