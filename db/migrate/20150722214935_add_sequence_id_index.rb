class AddSequenceIdIndex < ActiveRecord::Migration
  def change
    add_index :events, :sequence_id
  end
end
