class Events::StanceCreated < Event
  include Events::LiveUpdate
  include Events::Notify::ByEmail
  include Events::Notify::InApp
  include Events::Notify::Mentions
  include Events::Notify::Chatbots

  def self.publish!(stance)
    GenericWorker.perform_async('NotificationService', 'mark_as_read', "Poll", stance.poll_id, stance.participant_id)

    super stance,
          user: stance.participant.presence,
          discussion: stance.add_to_discussion? ? stance.poll.discussion : nil
  end

  def notify_mentions!
    return if eventable.poll.anonymous || eventable.poll.hide_results == 'until_closed'
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
