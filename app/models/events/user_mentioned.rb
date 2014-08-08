class Events::UserMentioned < Event
  def self.publish!(comment, mentioned_user)
    event = create!(kind: "user_mentioned", eventable: comment, user: mentioned_user)

    event.notify_user!
  end

  def comment
    eventable
  end

  def mentioned_user
    user
  end

  private

  def notify_user!
    unless mentioned_user == comment.user
      if mentioned_user.subscribed_to_mention_notifications?
        UserMailer.delay.mentioned(mentioned_user, comment)
      end
      notify!(mentioned_user)
    end
  end
end
