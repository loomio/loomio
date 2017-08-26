class UpdateReactionIndicies < ActiveRecord::Migration
  def change
    remove_index :reactions, :reactable_id
    add_index :reactions, [:reactable_id, :reactable_type]
  end
end
