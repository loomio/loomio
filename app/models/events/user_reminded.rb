class Events::UserReminded < Event
  include Events::Notify::InApp
  include Events::Notify::Users

  def self.publish!(model, actor, reminded_user)
    super model,
          user: actor,
          custom_fields: { reminded_user_id: reminded_user.id }
  end

  private

  def mailer
    "#{eventable.class}Mailer".constantize
  end

  def email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_recipients
    User.where(id: custom_fields['reminded_user_id'].to_i)
  end
end
