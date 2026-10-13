module HasTopicItems
  extend ActiveSupport::Concern

  included do
    has_many :topic_items, -> { includes :user, :itemable }, as: :itemable, dependent: :destroy
    has_one :created_topic_item, ->(itemable) { where(kind: itemable.created_topic_item_kind).order(:id) },
            as: :itemable, class_name: "TopicItem"
  end

  def created_topic_item
    return association(:created_topic_item).target if association(:created_topic_item).loaded?

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
