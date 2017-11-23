class Events::CommentRepliedTo < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::LiveUpdate

  private

  def email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_recipients
    User.where(id: eventable.parent.author_id)
  end
end
