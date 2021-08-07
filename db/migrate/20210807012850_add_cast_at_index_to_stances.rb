class AddCastAtIndexToStances < ActiveRecord::Migration[6.0]
  def change
    add_index :stances, [:poll_id, :cast_at], order: 'nulls first'
  end
end
