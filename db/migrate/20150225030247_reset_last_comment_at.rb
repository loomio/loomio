class ResetLastCommentAt < ActiveRecord::Migration
  def change
    puts "Resetting last_comment_at for all discussions"
    Comment.select('DISTINCT ON (discussion_id) id, *').order('discussion_id, comments.created_at desc').each do |comment|
      Discussion.where(id: comment.discussion_id).update_all(last_comment_at: comment.created_at)
    end
  end
end
