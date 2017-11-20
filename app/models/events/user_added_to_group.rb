class Events::UserAddedToGroup < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(membership, inviter)
    super membership, user: inviter
  end

  def email_users!
    mailer.send(kind, eventable.user, self).deliver_now
  end

  private

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
