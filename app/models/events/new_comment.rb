class Events::NewComment < Event
  def self.publish!(comment)
    create!(kind: 'new_comment',
            eventable: comment,
            discussion: comment.discussion,
            created_at: comment.created_at).tap { |event| EventBus.instance.broadcast 'new_comment', comment, event }
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
