class Events::OutcomePublished < Event
  include Events::SingleCommunityEvent

  def self.publish!(outcome, community)
    create(kind: "outcome_published",
           custom_fields: {community_id: community.id},
           user: outcome.author,
           eventable: outcome).tap { |e| EventBus.broadcast('outcome_published_event', e) }
  end
end
