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

  def mention_recipients
    eventable.new_mentioned_group_members
  end
end
