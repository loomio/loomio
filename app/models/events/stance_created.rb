class Events::StanceCreated < Event
  include Events::LiveUpdate
  include Events::Notify::ByEmail
  include Events::Notify::InApp
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty
  include Events::Notify::Author

  def self.publish!(stance)
    super stance,
          user: stance.participant.presence,
          discussion: stance.poll.discussion
  end

  def notify_author?
    false
  end

  def user
    super || AnonymousUser.new
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

  def notification_recipients
    if poll.notify_on_participate?
      User.where(id: poll.author_id).where.not(id: eventable[:participant_id])
    else
      User.none
    end
  end

  alias :email_recipients :notification_recipients
end
