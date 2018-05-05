class Events::DiscussionForked < Event
  def self.publish!(discussion, source)
    super discussion,
      discussion:    source,
      parent:        source.parent_event,
      user:          discussion.author,
      created_at:    discussion.created_at,
      custom_fields: { item_ids: discussion.forked_event_ids }
  end
end
