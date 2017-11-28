class Events::StanceCreated < Event
  include Events::LiveUpdate
  include Events::Notify::ByEmail
  include Events::Notify::InApp
  include Events::Notify::Mentions
  include Events::Notify::Author

  def self.publish!(stance)
    super stance,
          user: stance.participant,
          parent: stance.parent_event,
          discussion: stance.poll.discussion
  end

  def notify_author?
    !user.email_verified
  end

  private
  def author
    User.active.verified_first.find_by(email: eventable.author.email)
  end

  def notification_url
    @notification_url ||= polymorphic_url(eventable.poll)
  end

  def notification_recipients
    if poll.notify_on_participate?
      User.where(id: poll.author_id).without(eventable.participant)
    else
      User.none
    end
  end
  alias :email_recipients :notification_recipients

end
