module HasCreatedTopicItem
  def created_topic_item
    topic_items
      .where(kind: created_topic_item_kind)
      .order(:id)
      .first
  end

  def topic_item
    topic_items.where.not(topic_id: nil).first
  end

  def created_topic_item_kind
    :"#{self.class.name.downcase}_created"
  end

  def create_missing_created_topic_item!
    self.topic_items.create(
      kind: created_topic_item_kind,
      user_id: author_id,
      topic: topic,
      created_at: created_at
    )
  end
end
