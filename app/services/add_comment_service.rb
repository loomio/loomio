class AddCommentService
  def initialize(user, comment, discussion)
    @user = user
    @comment = comment
    @discussion = discussion
  end

  def commit!
    @comment.author = @user
    @comment.discussion = @discussion

    @user.ability.authorize! :add_comment, @discussion
    return false unless @comment.save

    event = Events::NewComment.publish!(@comment)
    @discussion.update_attribute(:last_comment_at, @comment.created_at)
    event
  end
end
