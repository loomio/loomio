class Events::NewComment < Event

  def self.publish!(comment)
    create(kind: 'new_comment',
           eventable: comment,
           discussion: comment.discussion,
           created_at: comment.created_at).tap { |e| EventBus.broadcast('new_comment_event', e) }
  end

  def group_key
    discussion.group.key
  end

  def discussion_key
    discussion.key
  end

  def comment
    eventable
  end
end
