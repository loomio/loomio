class Events::DiscussionMoved < Event
  include Events::LiveUpdate

  def self.publish!(discussion, actor, source_group)
    super discussion,
          user: actor,
          discussion: discussion,
          custom_fields: {source_group_id: source_group.id},
          created_at: Time.now
  end
end
