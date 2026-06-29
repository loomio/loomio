class Events::StanceCreated < Event
  include Events::LiveUpdate
  include Events::Notify::InApp
  include Events::Notify::Mentions
  include Events::Notify::Chatbots
  include Events::Notify::Subscribers

  def self.publish!(stance)
    MarkNotificationsAsReadWorker.perform_later("Poll", stance.poll_id, stance.participant_id)

    participant = stance.participant.presence
    publish_and_mark_read!(stance,
                           reader: participant,
                           user: participant,
                           topic: stance.add_to_thread? ? stance.poll.topic : nil)
  end

  def silence_mentions?
    eventable.poll.anonymous || eventable.poll.hide_results == 'until_closed'
  end

  def real_user
    eventable.real_participant
  end

  private

  def subscribed_eventable
    eventable
  end

  def notification_translation_values
    {
      name: eventable.participant.name,
      title: eventable.poll.title
    }
  end
end
