class Events::PollOpened < Event
  include Events::LiveUpdate
  include Events::Notify::ByEmail
  include Events::Notify::InApp
  include Events::Notify::Chatbots

  def self.publish!(poll)
    super poll,
          user: poll.author
  end

  private

  def email_recipients
    notification_recipients.where(id: Queries::UsersByVolumeQuery.normal_or_loud(eventable))
  end

  def notification_recipients
    User.active.distinct.joins(:stances).where(
      'stances.poll_id = ? AND stances.revoked_at IS NULL AND stances.latest = TRUE',
      eventable.id
    ).where.not(id: eventable.author_id)
  end
end
