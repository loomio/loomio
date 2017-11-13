class Events::UserAddedToGroup < Event
  include Events::Notify::InApp
  include Events::Notify::Users

  def self.publish!(membership, inviter)
    bulk_publish!(Array(membership), inviter).first
  end

  def self.bulk_publish!(memberships, inviter)
    memberships.map do |membership|
      new(
        kind: 'user_added_to_group',
        user: inviter,
        eventable: membership
      )
    end.tap do |events|
      import(events)
      events.map do |event|
        event.trigger!
        EventBus.broadcast('user_added_to_group_event', event)
      end
    end
  end

  def email_users!
    mailer.send(kind, eventable.user, self).deliver_now
  end

  private

  def notification_recipients
    User.where(id: eventable.user_id)
  end

  def notification_params
    super.merge(actor: eventable.inviter)
  end

  def mailer
    UserMailer
  end
end
