class AddCommentVotesCountToComments < ActiveRecord::Migration
  class Comment < ActiveRecord::Base
  end

  class CommentVote < ActiveRecord::Base
  end

  def up
    add_column :comments, :comment_votes_count, :integer, null: false, default: 0
    Comment.reset_column_information
    Comment.find_each do |comment|
      comment.update_attribute(:comment_votes_count, CommentVote.where(:comment_id => comment.id).count)
    end
  end

  def down
    remove_column :comments, :comment_votes_count
  end
end
