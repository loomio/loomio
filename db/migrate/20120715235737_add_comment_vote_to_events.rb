class AddCommentVoteToEvents < ActiveRecord::Migration
  def change
    add_column :events, :comment_vote_id, :integer
    add_index :events, :comment_vote_id
  end
end
