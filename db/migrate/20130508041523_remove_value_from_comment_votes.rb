class RemoveValueFromCommentVotes < ActiveRecord::Migration
  def up
    remove_column :comment_votes, :value
  end

  def down
    add_column :comment_votes, :value, :boolean, null: false, default: true
  end
end
