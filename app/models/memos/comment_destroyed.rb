class Memos::CommentDestroyed# < Memo
  def initialize(comment)
    @comment = comment
  end

  def as_hash
    {kind: 'CommentDestroyed', comment_id: @comment.id}
  end

  def publish
    PrivatePub.publish_to "/discussion-#{@comment.discussion_id}", {memo: as_hash}
  end
end
