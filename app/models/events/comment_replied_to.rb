class Events::CommentRepliedTo < Event
  def self.publish!(comment)
    return unless comment.parent && comment.parent.author != comment.author
    create(kind: 'comment_replied_to',
           eventable: comment,
           created_at: comment.created_at).tap { |e| EventBus.broadcast('comment_replied_to_event', e, comment.parent.author) }
  end
end
