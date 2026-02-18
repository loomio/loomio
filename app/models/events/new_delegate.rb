class Events::NewDelegate < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(membership, actor)
    super membership, user: actor, created_at: Time.now
  end

  private

  def notification_recipients
    User.where(id: eventable.user_id)
  end

  def email_recipients
    if eventable.email_volume_is_normal_or_loud?
      User.where(id: eventable.user_id)
    else
      User.none
    end
  end
end
