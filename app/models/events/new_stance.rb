class Events::NewStance < Event
  def self.publish!(stance)
    create(kind: "new_stance",
           user: stance.participant,
           eventable: stance,
           discussion: stance.poll.discussion,
           created_at: stance.created_at).tap { |e| EventBus.broadcast('new_stance_event', e) }
  end
end
