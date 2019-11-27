class Events::DiscussionForked < Event
  def self.publish!(discussion, source)
    super discussion,
      discussion:    source,
      user:          discussion.author,
      sequence_id:   discussion.forked_items.minimum(:sequence_id),
      created_at:    discussion.created_at,
      custom_fields: { item_ids: discussion.forked_event_ids }
  end
end
