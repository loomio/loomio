class Events::MembershipRequested < Event
  include Events::Notify::InApp
  include Events::Notify::Users

  private

  def notification_recipients
    eventable.admins.active
  end

  def email_recipients
    notification_recipients
  end

  def notification_params
    super.merge translation_values: {
      actor: eventable.requestor,
      name:  eventable.requestor&.name || eventable.name,
      title: eventable.group.full_name
    }
  end

  def mailer
    GroupMailer
  end
end
