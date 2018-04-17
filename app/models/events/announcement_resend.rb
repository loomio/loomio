class Events::AnnouncementResend < Event
  include Events::Notify::ByEmail

  def self.publish!(event)
    super model.eventable,
          user: event.user,
          custom_fields: {membership_ids: event.memberships.pending.pluck(:id)}
  end

  def memberships
    Membership.where(id: custom_fields['membership_ids'])
  end

  def email_recipients
    User.where(id: memberships.pluck(:user_id))
  end
end
