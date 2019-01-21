class Events::StanceCreated < Event
  include Events::LiveUpdate
  include Events::Notify::ByEmail
  include Events::Notify::InApp
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty
  include Events::Notify::Author

  def self.publish!(stance)
    super stance,
          user: stance.participant,
          parent: stance.parent_event,
          discussion: stance.poll.discussion
  end

  def notify_author?
    false
  end

  private
  def author
    User.active.verified.find_by(email: eventable.participant.email) || eventable.participant
  end

  def notification_translation_values
    {
      name: eventable.participant_for_client.name,
      title: eventable.poll.title
    }
  end

  def notification_url
    @notification_url ||= polymorphic_url(eventable.poll)
  end

  def notification_recipients
    if poll.notify_on_participate?
      User.where(id: poll.author_id).where.not(id: eventable.participant)
    else
      User.none
    end
  end
  alias :email_recipients :notification_recipients

end
