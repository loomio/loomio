class Events::UserMentioned < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(model, actor, memberships)
    super model,
          user: actor,
          custom_fields: { membership_ids: memberships.pluck(:id) }
  end

  def memberships
    @memberships ||= Membership.where(id: custom_fields['membership_ids'])
  end

  def members
    User.where(id: memberships.pluck(:user_id))
  end

  private
  def email_recipients
    notification_recipients.where(email_when_mentioned: true)
  end

  def notification_recipients
    members
  end
end
