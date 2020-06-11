class AllowNullStanceParticipant < ActiveRecord::Migration[5.2]
  def up
    change_column :stances, :participant_id, :integer, null: true
  end

  def down
    change_column :stances, :participant_id, :integer, null: false
  end
end
