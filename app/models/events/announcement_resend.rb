class Events::AnnouncementResend < Event
  include Events::Notify::ByEmail

  def self.publish!(event)
    super event.eventable,
      user: event.user,
      custom_fields: {
        membership_ids: Membership.pending.where(id: event.custom_fields['membership_ids']).pluck(:id),
        kind: event.custom_fields['kind']
      }
  end

  def email_method
    custom_fields['kind']
  end

  def email_recipients
    User.where(id: Membership.where(id: custom_fields['membership_ids']).pluck(:user_id))
  end
end
