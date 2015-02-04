class Events::CommentRepliedTo < Event
  after_create :notify_users!

  def self.publish!(reply)
    return unless reply.parent.present?
    create!(kind: 'comment_replied_to',
            eventable: reply,
            user: reply.author,
            created_at: reply.created_at)
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
