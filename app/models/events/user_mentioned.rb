class Events::UserMentioned < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(model, actor, users)
    super model,
          user: actor,
          custom_fields: { user_ids: users.pluck(:id) }
  end

  private
  def email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_recipients
    User.where(id: custom_fields['user_ids'])
  end
end
