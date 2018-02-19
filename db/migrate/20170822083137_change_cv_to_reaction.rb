class ChangeCvToReaction < ActiveRecord::Migration[4.2]
  def change
    add_column :comment_votes, :reaction, :string, default: "+1", null: false
    add_column :comment_votes, :reactable_type, :string, default: "Comment", null: false
    rename_column :comment_votes, :comment_id, :reactable_id
    rename_table :comment_votes, :reactions
  end
end
