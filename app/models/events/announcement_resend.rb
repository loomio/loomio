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
    'group_announced'
  end

  def email_subject_key
    "#{eventable.mailer.to_s.underscore}.resend"
  end

  def email_recipients
    # return User.none if eventable.is_a?(Poll) && !eventable.active? # do we want this?
    User.active.where(id: Membership.where(id: custom_fields['membership_ids']).pluck(:user_id))
  end
end
