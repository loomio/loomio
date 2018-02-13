class UpdateReactionIndicies < ActiveRecord::Migration[4.2]
  def change
    remove_index :reactions, :reactable_id
    add_index :reactions, [:reactable_id, :reactable_type]
  end
end
