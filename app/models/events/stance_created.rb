class Events::StanceCreated < Event
  include Events::LiveUpdate
  include Events::PollEvent
  include Events::Notify::Author

  def self.publish!(stance)
    create(kind: "stance_created",
           user: stance.participant,
           eventable: stance,
           discussion: stance.poll.discussion,
           parent: stance.parent_event,
           created_at: stance.created_at).tap { |e| EventBus.broadcast('stance_created_event', e) }
  end

  def notify_author?
    !user.email_verified
  end

  private
  def author
    User.verified.find_by(email: eventable.author.email) || eventable.author
  end

  def notification_url
    @notification_url ||= polymorphic_url(eventable.poll)
  end

  def notification_translation_title
    eventable.poll.title
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
