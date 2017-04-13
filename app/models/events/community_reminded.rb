class Events::CommunityReminded < Event
  def self.publish!(community, actor, poll)
    create(kind: "community_reminded",
           user: actor,
           custom_fields: {poll_id: poll.id},
           eventable: community).tap { |e| EventBus.broadcast('community_reminded_event', e) }
  end

  private

  def communities
    Array(self.eventable)
  end
end
