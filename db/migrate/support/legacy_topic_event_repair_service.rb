require_relative "legacy_event_record"

# Repairs the legacy events timeline using migration-only records. Current
# application models may require tables, columns, enums, or callbacks introduced
# after these repairs run, including the delivery-channel volume columns.
class LegacyTopicEventRepairService
  class IntegrityError < StandardError; end

  class TopicRecord < ActiveRecord::Base
    self.table_name = "topics"
  end

  class TopicReaderRecord < ActiveRecord::Base
    self.table_name = "topic_readers"
  end

  class DiscussionRecord < ActiveRecord::Base
    self.table_name = "discussions"
  end

  class PollRecord < ActiveRecord::Base
    self.table_name = "polls"
  end

  TOPICABLE_RECORDS = { "Discussion" => DiscussionRecord, "Poll" => PollRecord }.freeze
  ROOT_EVENT_KINDS = { "Discussion" => "new_discussion", "Poll" => "poll_created" }.freeze

  def self.repair!(topic_id)
    topic = TopicRecord.find_by(id: topic_id)
    return unless topic

    root = root_event_for(topic) || create_root_event!(topic)
    connection = ActiveRecord::Base.connection
    quoted_topic_id = connection.quote(topic.id)
    quoted_root_id = connection.quote(root.id)

    LegacyEventRecord.where(topic_id: topic.id, sequence_id: 0).where.not(id: root.id).update_all(sequence_id: nil)
    root.update_columns(topic_id: topic.id, parent_id: nil, sequence_id: 0, depth: 0, position: 0, position_key: "00000")

    # Preserve existing chronology, append newly exposed rows, and ensure every
    # non-root row is reachable from the topic root before rebuilding the tree.
    connection.execute(<<~SQL)
      WITH ordered AS (
        SELECT id, ROW_NUMBER() OVER (ORDER BY sequence_id ASC NULLS LAST, created_at, id) AS sequence_id
        FROM events
        WHERE topic_id = #{quoted_topic_id} AND id <> #{quoted_root_id}
      )
      UPDATE events
      SET sequence_id = ordered.sequence_id
      FROM ordered
      WHERE events.id = ordered.id
    SQL
    connection.execute(<<~SQL)
      UPDATE events child
      SET parent_id = #{quoted_root_id}
      WHERE child.topic_id = #{quoted_topic_id}
        AND child.id <> #{quoted_root_id}
        AND (
          child.parent_id IS NULL OR
          NOT EXISTS (
            SELECT 1 FROM events parent
            WHERE parent.id = child.parent_id AND parent.topic_id = child.topic_id
          )
        )
    SQL
    connection.execute(<<~SQL)
      WITH RECURSIVE ranked AS (
        SELECT
          id,
          parent_id,
          ROW_NUMBER() OVER (PARTITION BY parent_id ORDER BY sequence_id, id) AS sibling_position
        FROM events
        WHERE topic_id = #{quoted_topic_id}
      ), tree AS (
        SELECT id, 0 AS depth, 0::bigint AS position, '00000'::text AS position_key
        FROM ranked
        WHERE id = #{quoted_root_id}
        UNION ALL
        SELECT
          child.id,
          tree.depth + 1,
          child.sibling_position,
          tree.position_key || '-' || LPAD(child.sibling_position::text, 5, '0')
        FROM ranked child
        INNER JOIN tree ON tree.id = child.parent_id
      )
      UPDATE events
      SET depth = tree.depth,
          position = tree.position,
          position_key = tree.position_key
      FROM tree
      WHERE events.id = tree.id
    SQL
    connection.execute(<<~SQL)
      UPDATE events
      SET child_count = (
        SELECT COUNT(*) FROM events children
        WHERE children.parent_id = events.id AND children.topic_id = events.topic_id
      )
      WHERE topic_id = #{quoted_topic_id}
    SQL

    update_topic_sequence_info!(topic)
    verify!(topic.id)
  end

  def self.verify!(topic_id)
    connection = ActiveRecord::Base.connection
    failures = connection.select_value(<<~SQL).to_i
      SELECT COUNT(*)
      FROM events child
      LEFT JOIN events parent ON parent.id = child.parent_id AND parent.topic_id = child.topic_id
      WHERE child.topic_id = #{connection.quote(topic_id)}
        AND (
          child.sequence_id IS NULL OR
          child.position_key IS NULL OR
          (child.parent_id IS NOT NULL AND (parent.id IS NULL OR child.depth <> parent.depth + 1))
        )
    SQL
    raise IntegrityError, "Legacy topic #{topic_id} event repair failed" if failures.positive?
  end

  def self.root_event_for(topic)
    LegacyEventRecord.where(
      topic_id: topic.id,
      eventable_type: topic.topicable_type,
      eventable_id: topic.topicable_id,
      kind: root_event_kind(topic)
    ).order(:id).first
  end
  private_class_method :root_event_for

  def self.create_root_event!(topic)
    topicable = topicable_record_for(topic)
    LegacyEventRecord.create!(
      kind: root_event_kind(topic),
      eventable_type: topic.topicable_type,
      eventable_id: topicable.id,
      user_id: topicable.author_id,
      topic_id: topic.id,
      created_at: topicable.created_at,
      updated_at: topicable.created_at
    )
  end
  private_class_method :create_root_event!

  def self.topicable_record_for(topic)
    TOPICABLE_RECORDS.fetch(topic.topicable_type).find(topic.topicable_id)
  end
  private_class_method :topicable_record_for

  def self.root_event_kind(topic)
    ROOT_EVENT_KINDS.fetch(topic.topicable_type) do
      raise IntegrityError, "Legacy topic #{topic.id} has unsupported topicable type #{topic.topicable_type.inspect}"
    end
  end
  private_class_method :root_event_kind

  def self.update_topic_sequence_info!(topic)
    items = LegacyEventRecord.where(topic_id: topic.id).order(:sequence_id)
    sequence_ids = items.pluck(:sequence_id).compact
    ranges = RangeSet.reduce(RangeSet.ranges_from_list(sequence_ids))
    topic.update_columns(
      items_count: sequence_ids.length,
      ranges_string: RangeSet.serialize(ranges),
      last_activity_at: items.last&.created_at || topicable_record_for(topic).created_at
    )
    TopicReaderRecord.where(topic_id: topic.id).find_each do |reader|
      reader.update_columns(
        read_ranges_string: RangeSet.serialize(RangeSet.intersect_ranges(RangeSet.parse(reader.read_ranges_string), ranges))
      )
    end
  end
  private_class_method :update_topic_sequence_info!
end
