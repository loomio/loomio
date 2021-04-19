class Events::PollAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(poll: , actor: , stances:, recipient_user_ids: [], recipient_audience: nil, recipient_message: nil)
    super poll,
      user: actor,
      custom_fields: {stance_ids: stances.pluck(:id)},
      recipient_user_ids: Array(recipient_user_ids).uniq.compact,
      recipient_audience: recipient_audience.presence,
      recipient_message: recipient_message.presence)
  end

  private
  def stances
    Stance.where(id: custom_fields['stance_ids'])
  end

  def email_recipients
    notification_recipients.where(id: Queries::UsersByVolumeQuery.normal_or_loud(eventable))
  end

  def notification_recipients
    User.active.distinct.joins(:stances).where('stances.id IN (?)', custom_fields['stance_ids'])
  end
end
