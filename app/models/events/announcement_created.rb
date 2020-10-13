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

  def memberships
    @memberships ||= Membership.where(id: custom_fields['membership_ids'])
  end

  def kind
    'group_announced'
  end

  private

  def email_recipients
    User.active.where(id: memberships.where('volume >= ?', Membership.volumes[:normal]).pluck(:user_id))
  end

  def notification_recipients
    User.active.where(id: memberships.pluck(:user_id))
  end
end
