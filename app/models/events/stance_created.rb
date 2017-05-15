class Events::StanceCreated < Event
  include Events::LiveUpdate
  include Events::PollEvent

  def self.publish!(stance)
    create(kind: "stance_created",
           user: (stance.participant if stance.participant.is_logged_in?),
           eventable: stance,
           discussion: stance.poll.discussion,
           created_at: stance.created_at).tap { |e| EventBus.broadcast('stance_created_event', e) }
  end

  private

  def notification_recipients
    if poll.notify_on_participate?
      User.where(id: poll.author_id)
    else
      User.none
    end
  end
  alias :email_recipients :notification_recipients

end
