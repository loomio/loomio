module HasItemTags
  extend ActiveSupport::Concern

  KINDS = { 'new_discussion' => 'Discussion', 'poll_created' => 'Poll',
            'outcome_created' => 'Outcome', 'new_comment' => 'Comment' }.freeze

  included do
    scope :taggable, -> {
      where(KINDS.map { |kind, type| sanitize_sql_array(['(kind = ? AND itemable_type = ?)', kind, type]) }.join(' OR '))
    }

    # Tags remain shared metadata when poll visibility changes. CASE and
    # correlated lookups keep small batches from materializing every kept
    # discussion/comment. For a comment, follow its indexed parent chain rather
    # than rebuilding all descendants of discarded polls in the thread.
    scope :tags_visible, -> {
      where(<<~SQL.squish)
        CASE
        WHEN topic_items.kind = 'new_discussion' AND topic_items.itemable_type = 'Discussion' THEN EXISTS (
          SELECT 1 FROM discussions WHERE discussions.id = topic_items.itemable_id AND discarded_at IS NULL LIMIT 1 OFFSET 0
        )
        WHEN topic_items.kind = 'poll_created' AND topic_items.itemable_type = 'Poll' THEN EXISTS (
          SELECT 1 FROM polls WHERE polls.id = topic_items.itemable_id AND discarded_at IS NULL LIMIT 1 OFFSET 0
        )
        WHEN topic_items.kind = 'outcome_created' AND topic_items.itemable_type = 'Outcome' THEN EXISTS (
          SELECT 1 FROM outcomes JOIN polls ON polls.id = outcomes.poll_id
          WHERE outcomes.id = topic_items.itemable_id AND polls.discarded_at IS NULL LIMIT 1 OFFSET 0
        )
        WHEN topic_items.kind = 'new_comment' AND topic_items.itemable_type = 'Comment' THEN
          EXISTS (SELECT 1 FROM comments WHERE comments.id = topic_items.itemable_id AND discarded_at IS NULL LIMIT 1 OFFSET 0)
          AND NOT EXISTS (
            WITH RECURSIVE ancestors AS (
              SELECT id, parent_type, parent_id FROM comments WHERE id = topic_items.itemable_id
              UNION
              SELECT comments.id, comments.parent_type, comments.parent_id FROM comments JOIN ancestors
                ON ancestors.parent_type = 'Comment' AND comments.id = ancestors.parent_id
            )
            SELECT 1 FROM ancestors
            LEFT JOIN stances ON ancestors.parent_type = 'Stance' AND stances.id = ancestors.parent_id
            LEFT JOIN outcomes ON ancestors.parent_type = 'Outcome' AND outcomes.id = ancestors.parent_id
            JOIN polls ON polls.id = CASE ancestors.parent_type
              WHEN 'Poll' THEN ancestors.parent_id WHEN 'Stance' THEN stances.poll_id WHEN 'Outcome' THEN outcomes.poll_id END
            WHERE polls.discarded_at IS NOT NULL AND polls.topic_id = topic_items.topic_id LIMIT 1 OFFSET 0
          )
        ELSE FALSE END
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
    def tags_sql_for(model)
      tags_visible.where(itemable_type: model.name).where(arel_table[:itemable_id].eq(model.arel_table[:id]))
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
