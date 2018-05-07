class Events::UserMentioned < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(model, actor, mentioned_user)
    super model, user: actor, custom_fields: { mentioned_user_id: mentioned_user.id }
  end

  private

  def email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_recipients
    User.where(id: custom_fields['mentioned_user_id'].to_i)
  end
end
