class Memos::CommentUpdated < Memo
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
    "/group-#{@comment.group_id}"
  end
end
