class CommentDeleter
  def initialize(comment)
    @comment = comment
    @discussion = comment.discussion
  end

  def delete_comment
    @comment.destroy
    @discussion.refresh_last_comment_at!
  end
end
