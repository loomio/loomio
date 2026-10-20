module HasItemTags
  extend ActiveSupport::Concern

  KINDS = { 'new_discussion' => 'Discussion', 'poll_created' => 'Poll',
            'outcome_created' => 'Outcome', 'new_comment' => 'Comment' }.freeze

  included do
    scope :taggable, -> {
      where(KINDS.map { |kind, type| sanitize_sql_array(['(kind = ? AND itemable_type = ?)', kind, type]) }.join(' OR '))
    }

    # Tags are shared metadata. Withhold comment tags while any enclosing poll
    # hides results, even from viewers who have voted, so a single topic aggregate
    # is safe for every reader and for shared realtime publication. Follow actual
    # comment parents: the display-depth cap can make poll replies its siblings.
    scope :tags_visible, -> {
      taggable.where(<<~SQL.squish)
        (itemable_type = 'Discussion' AND itemable_id IN (SELECT id FROM discussions WHERE discarded_at IS NULL)) OR
        (itemable_type = 'Poll' AND itemable_id IN (SELECT id FROM polls WHERE discarded_at IS NULL)) OR
        (itemable_type = 'Outcome' AND itemable_id IN (
          SELECT outcomes.id FROM outcomes JOIN polls ON polls.id = outcomes.poll_id WHERE polls.discarded_at IS NULL
        )) OR
        (itemable_type = 'Comment' AND itemable_id IN (SELECT id FROM comments WHERE discarded_at IS NULL)
          AND NOT EXISTS (
            SELECT 1 FROM polls
            WHERE polls.topic_id = topic_items.topic_id
              AND (polls.discarded_at IS NOT NULL OR (polls.hide_results <> 0 AND polls.closed_at IS NULL))
              AND EXISTS (
                WITH RECURSIVE comment_parents AS (
                  SELECT parent_type, parent_id FROM comments WHERE id = topic_items.itemable_id
                  UNION
                  SELECT comments.parent_type, comments.parent_id FROM comments
                  JOIN comment_parents ON comment_parents.parent_type = 'Comment' AND comment_parents.parent_id = comments.id
                )
                SELECT 1 FROM comment_parents
                LEFT JOIN stances ON comment_parents.parent_type = 'Stance' AND stances.id = comment_parents.parent_id
                WHERE (comment_parents.parent_type = 'Poll' AND comment_parents.parent_id = polls.id)
                  OR stances.poll_id = polls.id
              )
          ))
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

  def tags_visible?
    self.class.tags_visible.exists?(id: id)
  end

  class_methods do
    # Search documents store explicit assignments, never the enclosing thread's
    # aggregate. The item lookup is indexed and also covers legacy missing roots.
    def tags_sql_for(type, id_sql)
      tags_visible.where(itemable_type: type).where("topic_items.itemable_id = #{id_sql}")
        .select(:tags).order(:id).limit(1).to_sql.then { |sql| "COALESCE((#{sql}), ARRAY[]::varchar[])" }
    end

    # Serialize tag edits with tree moves and other edits in the same topic. Only
    # tagged entries are read; the aggregate remains an indexed, rebuildable cache.
    def refresh_topic_tags!(topic_ids)
      Topic.where(id: topic_ids.compact.uniq).order(:id).with_write_lock do |topics|
        topics.each do |topic|
          names = tags_visible.where(topic_id: topic.id).where('cardinality(tags) > 0').pluck(Arel.sql('DISTINCT unnest(topic_items.tags)'))
          clean = TagService.clean_tag_names(names)
          next if topic.tags == clean

          topic.update!(tags: clean)
        end
      end
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
    self.class.refresh_topic_tags!([topic_id, topic_id_before_last_save])
    # Services return their existing topic object; refresh its derived fields too.
    topic.reload
    PgSearch::Document.where(searchable_type: itemable_type, searchable_id: itemable_id)
      .update_all(tags: !destroyed? && tags_visible? ? tags : [])
  end

  def publish_item_tag_changes
    MessageChannelService.publish_topic_models([self], topic: topic, group_id: topic.group_id)
  end
end
