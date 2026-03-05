class Events::UserMentioned < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::ByPush

  def self.publish!(model, actor, user_ids)
    super model, user: actor, custom_fields: { user_ids: }
  end

  private

  def email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_recipients
    User.active.verified.where(id: custom_fields['user_ids'])
  end
  
end
