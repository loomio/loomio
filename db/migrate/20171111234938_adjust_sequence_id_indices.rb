class AdjustSequenceIdIndices < ActiveRecord::Migration[4.2]
  def change
    remove_index :events, :sequence_id
    remove_index :events, [:discussion_id, :sequence_id]
    add_index    :events, [:discussion_id, :sequence_id], unique: true, order: {sequence_id: :asc}
  end
end
