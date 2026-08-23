module HasTopicItems
  extend ActiveSupport::Concern

  included do
    has_many :topic_items, -> { includes :user, :itemable }, as: :itemable, dependent: :destroy
  end

  def created_topic_item
    topic_items
      .where(kind: created_topic_item_kind)
      .order(:id)
      .first
  end

  def created_topic_item_kind
    :"#{self.class.name.downcase}_created"
  end

  def create_missing_created_topic_item!
    topic_items.create(
      kind: created_topic_item_kind,
      user_id: author_id,
      topic: topic,
      created_at: created_at
    )
  end
end
