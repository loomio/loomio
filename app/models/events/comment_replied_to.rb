class Events::CommentRepliedTo < Event
  after_create :notify_users!

  def self.publish!(comment)
    return unless comment.parent.present?
    event = create!(kind: 'comment_replied_to',
                    eventable: comment,
                    created_at: comment.created_at)

    ThreadMailer.delay.comment_replied_to(comment.parent.author, event)

    event
  end

  def comment
    eventable
  end

  def message_channel
    "/discussion-#{comment.discussion.key}"
  end

  private

  def notify_users!
    notify! comment.parent.author
  end

end
