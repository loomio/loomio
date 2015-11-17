class Events::CommentRepliedTo < Event
  def self.publish!(comment)
    return unless comment.parent.present?
    event = create!(kind: 'comment_replied_to',
                    eventable: comment,
                    created_at: comment.created_at)

    if comment.parent.author.email_when_mentioned?
      ThreadMailer.delay.comment_replied_to(comment.parent.author, event)
    end

    event.notify! comment.parent.author

    event
  end

  def group_key
    comment.group.key
  end

  def discussion_key
    eventable.discussion.key
  end

  def comment
    eventable
  end
end
