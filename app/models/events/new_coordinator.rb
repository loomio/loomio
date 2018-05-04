class Events::NewCoordinator < Event
  include Events::Notify::InApp

  def self.publish!(membership, actor)
    super membership, user: actor, created_at: Time.now
  end

  private

  def notification_recipients
    User.where(id: eventable.user_id)
  end
end
