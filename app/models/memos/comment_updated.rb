class Memos::CommentUpdated < Memo
  def self.publish!(comment)
    memo = new(comment)
    memo.publish!
    memo
  end

  def initialize(comment)
    @comment = comment
  end

  def kind
    'comment_updated'
  end

  def data
    CommentSerializer.new(@comment).as_json
  end

  def message_channel
    "/discussion-#{@comment.discussion_id}"
  end
end
