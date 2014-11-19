class Memos::CommentUnliked < Memo
  def initialize(comment_vote)
    @comment_vote = comment_vote
  end

  def kind
    'comment_unliked'
  end

  def data
    {comment_id: @comment_vote.comment_id,
     user_id: @comment_vote.user_id}
  end

  def message_channel
    "/discussion-#{@comment_vote.comment.discussion_id}"
  end
end
