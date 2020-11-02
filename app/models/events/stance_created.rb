class Events::StanceCreated < Event
  include Events::LiveUpdate
  include Events::Notify::ByEmail
  include Events::Notify::InApp
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(stance)
    super stance,
          user: stance.participant.presence,
          discussion: stance.poll.stances_in_discussion ? stance.poll.discussion : nil
  end

  def notify_mentions!
    return if eventable.poll.anonymous? || eventable.poll.hide_results_until_closed?
    super
  end

  def real_user
    eventable.real_participant
  end

  private

  def notification_translation_values
    {
      name: eventable.participant.name,
      title: eventable.poll.title
    }
  end

  def notification_url
    @notification_url ||= polymorphic_url(eventable.poll)
  end

  def email_recipients
    Queries::UsersByVolumeQuery.loud(eventable.poll)
                               .where.not(id: eventable.author)
                               .where.not(id: eventable.mentioned_users).distinct
  end
end
