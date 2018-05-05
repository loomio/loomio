class Events::DiscussionForked < Event
  def self.publish!(discussion, target_event)
    super discussion,
      discussion:  target_event.discussion,
      parent:      target_event.parent,
      sequence_id: target_event.sequence_id,
      user:        discussion.author,
      created_at:  discussion.created_at,
      custom_fields: {
        target_id: discussion.id,
        item_ids:  discussion.forked_event_ids
      }
  end
end
