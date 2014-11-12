class Memos::CommentDestroyed < Memo
  def self.publish!(comment)
    memo = new(comment)
    memo.publish!
    memo
  end

  def initialize(comment)
    @comment = comment
  end

  def kind
    'comment_destroyed'
  end

  def data
    {comment_id: @comment.id}
  end

  def message_channel
    "/discussion-#{@comment.discussion_id}"
  end
end
