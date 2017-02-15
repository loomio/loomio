class Events::UserAddedToGroup < Event
  include Events::EmailUser
  include Events::NotifyUser

  def self.publish!(membership, inviter, message = nil)
    bulk_publish!(Array(membership), inviter, message).first
  end

  def self.bulk_publish!(memberships, inviter, message = nil)
    memberships.map { |membership| new(kind: 'user_added_to_group', user: inviter, eventable: membership) }
               .tap { |events| import(events) }
               .tap { |events| events.map { |event| EventBus.broadcast('user_added_to_group_event', event, message: message) } }
  end

  private

  def email_users!
    mailer.send(kind, eventable.user, self, @trigger_args[:message]).deliver_now
  end

  def notification_recipients
    User.where(id: eventable.user_id)
  end

  def notification_actor
    eventable.inviter
  end

  def mailer
    UserMailer
  end
end
