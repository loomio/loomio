class Memos::CommentUnliked < Memo
  def initialize(user: , comment: )
    @comment = comment
    @user = user
  end

  def kind
    'comment_unliked'
  end

  def data
    {comment_id: @comment.id,
     user_id: @user.id}
  end

  def message_channel
    "/discussion-#{@comment.discussion_id}"
  end
end
