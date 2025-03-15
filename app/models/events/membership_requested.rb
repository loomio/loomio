class Events::MembershipRequested < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::WebPush

  def self.publish!(membership_request)
    super membership_request, user: membership_request.requestor
  end

  private

  def notification_recipients
    eventable.admins.active
  end

  def email_recipients
    Queries::UsersByVolumeQuery.
      email_notifications(eventable.group).
      where(id: eventable.admins.active.pluck(:id))
  end

  def notification_actor
    eventable.requestor
  end

  def notification_translation_values
    { name: eventable.requestor&.name || eventable.name, title: eventable.group.full_name }
  end
end
