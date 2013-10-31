class AddCommentService
  def initialize(user_or_comment, comment = nil, discussion = nil)
    if comment.nil?
      @comment = user_or_comment
      @user = @comment.author
      @discussion = @comment.discussion
    else
      @user = user_or_comment
      @comment = comment
      @discussion = discussion
      @comment.author = @user
      @comment.discussion = @discussion
    end
  end

  def commit!
    @user.ability.authorize! :add_comment, @discussion
    return false unless @comment.save

    event = Events::NewComment.publish!(@comment)
    @discussion.update_attribute(:last_comment_at, @comment.created_at)
    event
  end
end
