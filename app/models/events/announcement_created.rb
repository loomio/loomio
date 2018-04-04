class Events::AnnouncementCreated < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.bulk_publish!(model, actor, memberships, params = {})
    Array(memberships).map do |membership|
      build(model,
        user: actor,
        custom_fields: params.slice(:kind).merge(membership_id: membership.id)
      )
    end.tap do |events|
      import events
      events.map(&:trigger!)
    end
  end

  private

  def email_users!
    return unless membership.user.email_announcements
    eventable.send(:mailer).delay.send(custom_fields['kind'], membership, self)
  end

  def notification_recipients
    User.where(id: membership.user_id)
  end

  def membership
    @membership ||= Membership.find(custom_fields['membership_id'])
  end
end
