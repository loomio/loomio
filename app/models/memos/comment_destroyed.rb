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
    {
      comment_id: @comment.id,
      discussion_id: @comment.discussion_id,
      event_id: @comment.created_event.id
    }
  end

  def message_channel
    @comment.group.message_channel
  end
end
