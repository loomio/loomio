class Events::MembershipRequested < Event
  include Events::NotifyUser
  include Events::EmailUser

  def self.publish!(membership_request)
    create(kind: "membership_requested",
           eventable: membership_request).tap { |e| EventBus.broadcast('membership_requested_event', e) }
  end

  private

  def notification_recipients
    eventable.admins.active
  end

  def email_recipients
    notification_recipients
  end

  def notification_actor
    eventable.requestor
  end

  def notification_translation_values
    { name: eventable.requestor&.name || eventable.name, title: eventable.group.full_name }
  end

  def mailer
    GroupMailer
  end
end
