class AddIndicesToDrafts < ActiveRecord::Migration
  def change
    add_index :drafts, [:user_id, :draftable_type, :draftable_id], unique: true
  end
end
