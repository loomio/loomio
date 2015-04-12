class Events::CommentRepliedTo < Event
  def self.publish!(comment)
    return unless comment.parent.present?
    event = create!(kind: 'comment_replied_to',
                    eventable: comment,
                    created_at: comment.created_at)

    ThreadMailer.delay.comment_replied_to(comment.parent.author, event)
    event.notify! comment.parent.author

    event
  end

  def discussion_key
    eventable.discussion.key
  end

  def comment
    eventable
  end
end
