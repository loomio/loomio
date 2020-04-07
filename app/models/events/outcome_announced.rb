class Events::OutcomeAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(model, actor, users)
    super model,
          user: actor,
          custom_fields: { user_ids: users.pluck(:id)}.compact
  end

  private

  def email_recipients
    notification_recipients.where(id: Queries::UsersByVolumeQuery.normal_or_loud(eventable))
  end

  def notification_recipients
    User.active.where(id: custom_fields['user_ids'])
  end
end
