class Events::StanceCreated < Event
  include Events::LiveUpdate
  include Events::PollEvent
  include Events::Notify::Author

  def self.publish!(stance)
    super(stance, user: stance.participant, discussion: stance.poll.discussion)
  end

  def notify_author?
    !user.email_verified
  end

  private
  def author
    User.verified.find_by(email: eventable.author.email) || eventable.author
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
