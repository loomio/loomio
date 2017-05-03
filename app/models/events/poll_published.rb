class Events::PollPublished < Event
  include Events::SingleCommunityEvent

  def self.publish!(poll, actor, community, message = "")
    create(kind: "poll_published",
           user: actor,
           custom_fields: {community_id: community.id, message: message},
           eventable: poll).tap { |e| EventBus.broadcast('poll_published_event', e) }
  end
end
