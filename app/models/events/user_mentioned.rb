class Events::UserMentioned < Event
  after_create :notify_users!

  def self.publish!(comment, mentioned_user)
    create!(kind: "user_mentioned", eventable: comment, user: mentioned_user)
  end

  def comment
    eventable
  end

  def mentioned_user
    user
  end

  private

  def notify_users!
    unless mentioned_user == comment.user
      if mentioned_user.subscribed_to_mention_notifications?
        UserMailer.mentioned(mentioned_user, comment).deliver
      end
      notify!(mentioned_user)
    end
  end

  handle_asynchronously :notify_users!
end
