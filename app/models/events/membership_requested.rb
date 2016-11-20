class Events::MembershipRequested < Event
  def self.publish!(membership_request)
    create(kind: "membership_requested",
           eventable: membership_request).tap { |e| EventBus.broadcast('membership_requested_event', e) }
  end

  def users_to_notify
    eventable.admins.active
  end

  private

  def notification_actor
    eventable.requestor
  end

  def notification_translation_values
    { name: eventable.requestor&.name || eventable.name, group: eventable.group.full_name }
  end
end
