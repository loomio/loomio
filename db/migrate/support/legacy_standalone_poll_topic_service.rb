require_relative "legacy_topic_event_repair_service"

# Migration-only repair for standalone poll topics created before every
# timeline row was required to belong to a topic. It deliberately works with
# the legacy events table so later Event-to-TopicItem application refactors do
# not change the meaning of the 2026-05 migrations.
class LegacyStandalonePollTopicService
  def self.mark_closed_topics_read(dry_run: false, progress: nil)
    stats = { topics: 0, readers_created: 0, readers_updated: 0 }
    processed = 0

    Poll.closed.kept.joins(:topic).where(topics: { topicable_type: "Poll" }).find_each do |poll|
      processed += 1
      progress&.call("Processing poll #{processed} (id=#{poll.id})...") if (processed % 100).zero?

      topic = poll.topic
      sequence_ids = LegacyEventRecord.where(topic_id: topic.id).where.not(sequence_id: nil).order(:sequence_id).pluck(:sequence_id)
      ranges = RangeSet.ranges_from_list(sequence_ids)
      next if ranges.empty?

      stats[:topics] += 1
      read_ranges_string = RangeSet.serialize(ranges)
      timestamp = Time.zone.now
      reader_attrs = closed_topic_reader_attrs(poll, topic, timestamp)
      audience_user_ids = reader_attrs.map { |attrs| attrs[:user_id] }
      existing_user_ids = TopicReader.where(topic_id: topic.id, user_id: audience_user_ids).pluck(:user_id).to_set
      missing_reader_attrs = reader_attrs.reject { |attrs| existing_user_ids.include?(attrs[:user_id]) }
      active_reader_scope = TopicReader.active.where(topic_id: topic.id)

      if dry_run
        stats[:readers_created] += missing_reader_attrs.length
        stats[:readers_updated] += active_reader_scope.count + missing_reader_attrs.length
        next
      end

      TopicReader.insert_all(missing_reader_attrs, unique_by: :index_topic_readers_on_topic_id_and_user_id) if missing_reader_attrs.any?
      stats[:readers_created] += missing_reader_attrs.length
      stats[:readers_updated] += TopicReader.active.where(topic_id: topic.id).update_all(
        read_ranges_string: read_ranges_string,
        last_read_at: timestamp,
        updated_at: timestamp
      )
    end

    update_topic_reader_counters unless dry_run
    stats
  end

  def self.backfill_stance_events(dry_run: false, repair: true, mark_closed_read: true, progress: nil, progress_every: 100)
    progress&.call("Finding standalone poll stance events to attach...")
    rows = if dry_run
      connection.select_all("SELECT topic_id FROM (#{stance_event_candidates_sql}) candidate_events")
    else
      connection.exec_query(<<~SQL.squish)
        WITH candidate_events AS (#{stance_event_candidates_sql})
        UPDATE events
        SET topic_id = candidate_events.topic_id,
            sequence_id = NULL,
            parent_id = candidate_events.parent_id,
            position = 0,
            position_key = NULL,
            depth = 1,
            updated_at = CURRENT_TIMESTAMP
        FROM candidate_events
        WHERE events.id = candidate_events.event_id
        RETURNING events.topic_id
      SQL
    end

    attached_topic_ids = rows.map { |row| row["topic_id"] }.uniq
    progress&.call("Found #{rows.length} stance events to attach across #{attached_topic_ids.length} standalone poll topics.")
    repair_topic_ids = topic_ids_newest_first(attached_topic_ids + unsequenced_stance_event_topic_ids)

    if repair && !dry_run
      repair_topic_ids.each.with_index(1) do |topic_id, index|
        progress&.call("Repairing standalone poll topic #{index}/#{repair_topic_ids.length} (topic_id=#{topic_id})...") if (index % progress_every).zero?
        LegacyTopicEventRepairService.repair!(topic_id)
      end
    end

    stats = { events: rows.length, topics: attached_topic_ids.length, repair_topics: repair_topic_ids.length }
    stats[:closed_read] = mark_closed_topics_read(dry_run: dry_run, progress: progress) if mark_closed_read
    stats
  end

  def self.closed_topic_reader_attrs(poll, topic, timestamp)
    if topic.group_id.present?
      Membership.active.accepted.where(group_id: topic.group_id).pluck(:user_id, :volume).map do |user_id, volume|
        closed_topic_reader_attr(topic, user_id, volume || TopicReader.volumes[:normal], false, false, timestamp)
      end
    else
      user_ids = ([ poll.author_id ] + poll.stances.where.not(participant_id: nil).pluck(:participant_id)).compact.uniq
      user_ids.map do |user_id|
        closed_topic_reader_attr(topic, user_id, TopicReader.volumes[:normal], true, user_id == poll.author_id, timestamp)
      end
    end
  end
  private_class_method :closed_topic_reader_attrs

  def self.closed_topic_reader_attr(topic, user_id, volume, guest, admin, timestamp)
    {
      topic_id: topic.id,
      user_id: user_id,
      volume: volume,
      guest: guest,
      admin: admin,
      created_at: timestamp,
      updated_at: timestamp
    }
  end
  private_class_method :closed_topic_reader_attr

  def self.update_topic_reader_counters
    topic_ids = Poll.closed.kept.joins(:topic).where(topics: { topicable_type: "Poll" }).pluck("topics.id")
    topic_ids.each_slice(1_000) do |ids|
      connection.execute(<<~SQL.squish)
        UPDATE topics
        SET seen_by_count = counts.seen_by_count,
            members_count = counts.members_count
        FROM (
          SELECT topic_id,
                 COUNT(*) FILTER (WHERE last_read_at IS NOT NULL) AS seen_by_count,
                 COUNT(*) FILTER (WHERE revoked_at IS NULL) AS members_count
          FROM topic_readers
          WHERE topic_id IN (#{ids.map(&:to_i).join(',')})
          GROUP BY topic_id
        ) counts
        WHERE topics.id = counts.topic_id
      SQL
    end
  end
  private_class_method :update_topic_reader_counters

  def self.unsequenced_stance_event_topic_ids
    connection.select_values(<<~SQL.squish)
      SELECT DISTINCT events.topic_id
      FROM events
      INNER JOIN stances ON stances.id = events.eventable_id AND events.eventable_type = 'Stance'
      INNER JOIN polls ON polls.id = stances.poll_id
      INNER JOIN topics ON topics.id = polls.topic_id
        AND topics.topicable_type = 'Poll'
        AND topics.topicable_id = polls.id
      WHERE events.kind IN ('stance_created', 'stance_updated')
        AND events.topic_id = polls.topic_id
        AND events.sequence_id IS NULL
    SQL
  end
  private_class_method :unsequenced_stance_event_topic_ids

  def self.topic_ids_newest_first(topic_ids)
    ids = Array(topic_ids).uniq
    return [] if ids.empty?

    Topic
      .joins("INNER JOIN polls ON polls.id = topics.topicable_id AND topics.topicable_type = 'Poll'")
      .where(id: ids)
      .order("polls.created_at DESC, topics.id DESC")
      .pluck(:id)
  end
  private_class_method :topic_ids_newest_first

  def self.stance_event_candidates_sql
    <<~SQL.squish
      SELECT DISTINCT ON (events.eventable_id)
             events.id AS event_id,
             polls.topic_id AS topic_id,
             root_events.id AS parent_id
      FROM events
      INNER JOIN stances ON stances.id = events.eventable_id AND events.eventable_type = 'Stance'
      INNER JOIN polls ON polls.id = stances.poll_id
      INNER JOIN topics ON topics.id = polls.topic_id
        AND topics.topicable_type = 'Poll'
        AND topics.topicable_id = polls.id
      INNER JOIN events root_events ON root_events.eventable_type = 'Poll'
        AND root_events.eventable_id = polls.id
        AND root_events.kind = 'poll_created'
        AND root_events.topic_id = polls.topic_id
      WHERE events.kind IN ('stance_created', 'stance_updated')
        AND events.topic_id IS NULL
        AND stances.latest = TRUE
        AND stances.revoked_at IS NULL
        AND stances.cast_at IS NOT NULL
        AND stances.reason IS NOT NULL
        AND stances.reason NOT IN ('', '<p></p>')
        AND (polls.closed_at IS NOT NULL OR polls.hide_results != 2)
        AND NOT EXISTS (
          SELECT 1 FROM events existing_events
          WHERE existing_events.eventable_type = 'Stance'
            AND existing_events.eventable_id = events.eventable_id
            AND existing_events.kind IN ('stance_created', 'stance_updated')
            AND existing_events.topic_id = polls.topic_id
        )
      ORDER BY events.eventable_id, events.created_at, events.id
    SQL
  end
  private_class_method :stance_event_candidates_sql

  def self.connection
    ActiveRecord::Base.connection
  end
  private_class_method :connection
end
