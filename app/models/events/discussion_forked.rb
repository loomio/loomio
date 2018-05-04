class Events::DiscussionForked < Event
  def self.publish!(discussion, actor, target_discussion)
    super discussion,
      discussion: discussion,
      user: actor,
      created_at: target_discussion.created_at
      custom_fields: {
        target_id: target_discussion.id,
        item_ids:  target_discussion.item_ids
      }
  end
end
