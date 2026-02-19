class EventService
  def self.remove_from_thread(event:, actor:)
    discussion = event.discussion
    raise CanCan::AccessDenied.new unless event.kind == 'discussion_edited'
    actor.ability.authorize! :remove_events, discussion

    event.update(topic_id: nil)
    discussion.update_sequence_info!
    GenericWorker.perform_async('SearchService', 'reindex_by_discussion_id', discussion.id)

    EventBus.broadcast('event_remove_from_thread', event)
    event
  end

  def self.move_comments(discussion:, actor:, params:)
    ids = Array(params[:forked_event_ids]).compact
    source_topic = Event.find(ids.first).topic
    source = source_topic&.topicable

    actor.ability.authorize! :move_comments, source
    actor.ability.authorize! :move_comments, discussion
    MoveCommentsWorker.perform_async(ids, source.id, discussion.id)
  end

  def self.repair_thread(topic)
    return unless topic
    topicable = topic.topicable

    # ensure topicable.created_event exists
    unless topicable.created_event
      Event.import [Event.new(kind: topicable.created_event_kind.to_s,
                              user_id: topicable.author_id,
                              eventable_id: topicable.id,
                              eventable_type: topicable.class.name,
                              created_at: topicable.created_at)]
      topicable.reload
    end

    created_event = topicable.created_event
    Event.where(topic_id: topic.id, sequence_id: nil).where.not(id: created_event.id).order(:id).each(&:set_sequence_id!)

    # rebuild ancestry of events based on eventable relationships
    items = Event.where(topic_id: topic.id).where.not(id: created_event.id).order(:sequence_id)
    items.update_all(parent_id: created_event.id, position: 0, position_key: nil, depth: 1)
    items.reload.compact.each(&:set_parent_and_depth!)

    parent_ids = items.pluck(:parent_id).compact.uniq

    reset_child_positions(created_event.id, nil)
    Event.where(id: parent_ids).order(:depth).each do |parent_event|
      parent_event.reload
      reset_child_positions(parent_event.id, parent_event.position_key)
    end

    ActiveRecord::Base.connection.execute(
      "UPDATE events
       SET descendant_count = (
         SELECT count(descendants.id)
         FROM events descendants
         WHERE
            descendants.topic_id = events.topic_id AND
            descendants.id != events.id AND
            descendants.position_key like CONCAT(events.position_key, '%')
      ), child_count = (
        SELECT count(children.id) FROM events children
        WHERE children.parent_id = events.id AND children.topic_id IS NOT NULL
      )
      WHERE topic_id = #{topic.id.to_i}")

    created_event.reload.update_child_count
    created_event.update_descendant_count
    topic.update_sequence_info!

    # ensure all the topic_readers have valid read_ranges values
    TopicReader.where(topic_id: topic.id).each do |reader|
      reader.update_columns(
        read_ranges_string: RangeSet.serialize(
          RangeSet.intersect_ranges(reader.read_ranges, topic.ranges)
        )
      )
    end
  end

  # Keep old method name for compatibility with RepairThreadWorker
  def self.repair_discussion(discussion_id)
    discussion = Discussion.find_by(id: discussion_id)
    return unless discussion&.topic
    repair_thread(discussion.topic)
  end

  def self.reset_child_positions(parent_id, parent_position_key)

    position_key_sql = if parent_position_key.nil?
      "CONCAT(REPEAT('0',5-LENGTH(CONCAT(t.seq))), t.seq)"
    else
      "CONCAT('#{parent_position_key}-', CONCAT(REPEAT('0',5-LENGTH(CONCAT(t.seq) ) ), t.seq) )"
    end
    ActiveRecord::Base.connection.execute(
      "UPDATE events SET position = t.seq, position_key = #{position_key_sql}
        FROM (
          SELECT id AS id, row_number() OVER(ORDER BY sequence_id) AS seq
          FROM events
          WHERE parent_id = #{parent_id}
          AND   topic_id IS NOT NULL
        ) AS t
      WHERE events.id = t.id and
            events.position is distinct from t.seq")
    SequenceService.drop_seq!('events_position', parent_id)
  end

  def self.repair_all_threads
    Topic.pluck(:id).each do |id|
      RepairThreadWorker.perform_async(id)
    end
  end
end
