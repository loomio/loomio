module HasItemTags
  extend ActiveSupport::Concern

  KINDS = { 'new_discussion' => 'Discussion', 'poll_created' => 'Poll',
            'outcome_created' => 'Outcome', 'new_comment' => 'Comment' }.freeze

  included do
    scope :taggable, -> {
      where(KINDS.map { |kind, type| sanitize_sql_array(['(kind = ? AND itemable_type = ?)', kind, type]) }.join(' OR '))
    }

    # Tags remain shared metadata when poll visibility changes. Only discarded
    # contributions leave the aggregate; result privacy belongs to search/content.
    scope :tags_visible, -> {
      taggable.where(<<~SQL.squish)
        (itemable_type = 'Discussion' AND itemable_id IN (SELECT id FROM discussions WHERE discarded_at IS NULL)) OR
        (itemable_type = 'Poll' AND itemable_id IN (SELECT id FROM polls WHERE discarded_at IS NULL)) OR
        (itemable_type = 'Outcome' AND itemable_id IN (
          SELECT outcomes.id FROM outcomes JOIN polls ON polls.id = outcomes.poll_id WHERE polls.discarded_at IS NULL
        )) OR
        (itemable_type = 'Comment' AND itemable_id IN (SELECT id FROM comments WHERE discarded_at IS NULL)
          AND itemable_id NOT IN (#{Comment.under_polls(Poll.discarded.where('polls.topic_id = topic_items.topic_id')).select(:id).to_sql}))
      SQL
    }

    scope :tagged_replies, -> { tags_visible.where('sequence_id > 0 AND cardinality(tags) > 0') }

    before_validation :normalize_item_tags
    validate :item_tags_are_supported
    after_save :refresh_item_tags, if: -> { saved_change_to_tags? || (tags.any? && saved_change_to_topic_id?) }
    after_destroy :refresh_item_tags, if: -> { tags.any? && !destroyed_with_topic? }
    after_save_commit :publish_item_tag_changes, if: :saved_change_to_tags?
  end

  def taggable?
    KINDS[kind] == itemable_type
  end

  def tags_assignable?
    self.class.tags_visible.exists?(id: id)
  end

  class_methods do
    # Search documents store explicit assignments, never the enclosing thread's
    # aggregate. The item lookup is indexed and also covers legacy missing roots.
    def tags_sql_for(type, id_sql)
      tags_visible.where(itemable_type: type).where("topic_items.itemable_id = #{id_sql}")
        .select(:tags).order(:id).limit(1).to_sql.then { |sql| "COALESCE((#{sql}), ARRAY[]::varchar[])" }
    end
  end

  private

  def normalize_item_tags
    self.tags = TagService.clean_tag_names(tags)
  end

  def item_tags_are_supported
    errors.add(:tags, :invalid) if tags.any? && !taggable?
  end

  def refresh_item_tags
    TagService.refresh_topic_tags!([topic_id, topic_id_before_last_save])
    # Services return their existing topic object; refresh its derived fields too.
    topic.reload
    PgSearch::Document.where(searchable_type: itemable_type, searchable_id: itemable_id)
      .update_all(tags: destroyed? ? [] : tags)
  end

  def publish_item_tag_changes
    MessageChannelService.publish_topic_models([self], topic: topic, group_id: topic.group_id)
  end
end
