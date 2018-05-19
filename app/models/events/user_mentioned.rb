class Events::UserMentioned < Events::AnnouncementCreated
  def self.publish!(model, actor, memberships)
    super model, actor, memberships, 'user_mentioned'
  end

  private
  def email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_recipients
    members
  end
end
