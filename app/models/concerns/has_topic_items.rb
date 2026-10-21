module HasTopicItems
  extend ActiveSupport::Concern

  included do
    after_update :refresh_topic_tags_for_visibility, if: -> { saved_changes.key?('discarded_at') }
    has_many :topic_items, -> { includes :user, :itemable }, as: :itemable, dependent: :destroy
    has_one :created_topic_item, ->(itemable) { where(kind: itemable.created_topic_item_kind).order(:id) },
            as: :itemable, class_name: "TopicItem"
  end

  # Assignments survive discarding; only the thread summaries change. Rebuild
  # those summaries in the same transaction as the content change.
  def refresh_topic_tags_for_visibility
    TopicItem.refresh_topic_tags!([topic_id])
  end
  private :refresh_topic_tags_for_visibility

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
