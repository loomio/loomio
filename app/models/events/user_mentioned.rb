class Events::UserMentioned < Event
  include Events::NotifyUser
  include Events::EmailUser

  def self.publish!(model, actor, mentioned_user)
    create(kind: 'user_mentioned',
           eventable: model,
           user: actor,
           custom_fields: { mentioned_user_id: mentioned_user.id },
           created_at: model.created_at).tap { |e| EventBus.broadcast('user_mentioned_event', e) }
  end

  private

  def email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_recipients
    User.where(id: custom_fields['mentioned_user_id'].to_i)
  end
end
