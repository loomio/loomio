class Events::PollAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(model, actor, stances)
    super model,
      user: actor,
      custom_fields: {stance_ids: stances.pluck(:id)}
  end

  private

  def stances
    Stance.where(id: custom_fields['stance_ids'])
  end

  def email_recipients
    notification_recipients.where(id: Queries::UsersByVolumeQuery.normal_or_loud(eventable))
  end

  def notification_recipients
    User.active.joins(:stances).where('stances.id IN (?)', custom_fields['stance_ids'])
  end
end
