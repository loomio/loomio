class Events::UserAddedToGroup < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(membership, inviter)
    super membership, user: inviter
  end

  private

  def notification_recipients
    User.where(id: eventable.user_id)
  end
  alias :email_recipients :notification_recipients

  def notification_actor
    eventable.inviter
  end
end
