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
    @comment.group.message_channel
  end
end
