class Events::AnnouncementCreated < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(model, actor, memberships, kind)
    super model,
          user: actor,
          custom_fields: { membership_ids: memberships.pluck(:id), kind: kind }
  end

  def memberships
    @memberships ||= Membership.where(id: custom_fields['membership_ids'])
  end

  private

  def email_method
    custom_fields['kind']
  end

  def email_recipients
    notification_recipients.
      where(id: Queries::UsersByVolumeQuery.normal_or_loud(eventable))
  end

  def notification_recipients
    User.active.where(id: memberships.pluck(:user_id))
  end
end
