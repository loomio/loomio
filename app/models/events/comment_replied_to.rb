class Events::CommentRepliedTo < Event
  def self.publish!(comment)
    return unless comment.parent.present?
    event = create!(kind: 'comment_replied_to',
                    eventable: comment,
                    created_at: comment.created_at)

    if comment.parent.author != comment.author
      ThreadMailer.delay.comment_replied_to(comment.parent.author, event) if comment.parent.author.email_when_mentioned?
      event.notify! comment.parent.author
    end

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
