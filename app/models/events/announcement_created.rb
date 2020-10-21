class Events::AnnouncementCreated < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(model, actor, memberships, message = '')
    super model,
          user: actor,
          custom_fields: {
            message: message,
            membership_ids: memberships.pluck(:id)
          }.compact
  end

  # def email_users!
  #   memberships.each do |m|
  #     GroupMailer.delay(queue: :notification_emails).group_announced(m.user_id, self.id)
  #   end
  # end

  def memberships
    @memberships ||= Membership.where(id: custom_fields['membership_ids'])
  end

  private

  def notification_recipients
    User.active.where(id: memberships.pluck(:user_id))
  end
end
