module Events::Notify::Mentions
  def trigger!
    super
    self.notify_mentions!
  end

  # send event notifications
  def notify_mentions!
    mention_recipients.each { |mention| Events::UserMentioned.publish!(eventable.mentionable, user, mention) }
  end
  handle_asynchronously :notify_mentions!

  # who should receive mentions from this event?
  def mention_recipients
    User.none
  end
end
