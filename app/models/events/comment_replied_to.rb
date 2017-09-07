class Events::CommentRepliedTo < Event
  include Events::Notify::InApp
  include Events::Notify::Users
  include Events::LiveUpdate

  def self.publish!(comment)
    super if comment.parent && comment.parent.author != comment.author
  end

  private

  def email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_recipients
    User.where(id: eventable.parent.author_id)
  end

  def mailer
    ThreadMailer
  end
end
