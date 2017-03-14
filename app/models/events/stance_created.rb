class Events::StanceCreated < Event
  include Events::LiveUpdate

  def self.publish!(stance)
    create(kind: "stance_created",
           user: (stance.participant if stance.participant.is_logged_in?),
           eventable: stance,
           discussion: stance.poll.discussion,
           created_at: stance.created_at).tap { |e| EventBus.broadcast('stance_created_event', e) }
  end
end
