class Events::CommentRepliedTo < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::LiveUpdate

  def self.publish!(comment)
    super comment, user: comment.author
  end

  private

  def email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_recipients
    eventable.members.where('users.id': eventable.parent.author_id)
  end
end
