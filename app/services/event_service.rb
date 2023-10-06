class EventService
  def self.remove_from_thread(event:, actor:)
    discussion = event.discussion
    raise CanCan::AccessDenied.new unless event.kind == 'discussion_edited'
    actor.ability.authorize! :remove_events, discussion

    event.update(discussion_id: nil)
    discussion.thread_item_destroyed!
    GenericWorker.perform_async('SearchService', 'reindex_by_discussion_id', discussion.id)
    
    EventBus.broadcast('event_remove_from_thread', event)
    event
  end

  def self.move_comments(discussion:, actor:, params:)
    # handle parent comments = events where parent_id is source.created_event.id
      # move all events which are children of above parents (comment parent id untouched)
    # handle any reply comments that don't have parent_id in given ids

    ids = Array(params[:forked_event_ids]).compact
    source = Event.find(ids.first).discussion

    actor.ability.authorize! :move_comments, source
    actor.ability.authorize! :move_comments, discussion
    MoveCommentsWorker.perform_async(ids, source.id, discussion.id)
  end

  def self.repair_thread(discussion_id)
    discussion = Discussion.find_by(id: discussion_id)
    return unless discussion

    # ensure discussion.created_event exists
    unless discussion.created_event
      Event.import [Event.new(kind: 'new_discussion',
                              user_id: discussion.author_id,
                              eventable_id: discussion.id,
                              eventable_type: "Discussion",
                              created_at: discussion.created_at)]
      discussion.reload
    end

    Event.where(discussion_id: discussion_id, sequence_id: nil).order(:id).each(&:set_sequence_id!)

    # rebuild ancestry of events based on eventable relationships
    items = Event.where(discussion_id: discussion.id).order(:sequence_id)
    items.update_all(parent_id: discussion.created_event.id, position: 0, position_key: nil, depth: 1)
    items.reload.compact.each(&:set_parent_and_depth!)

    parent_ids = items.pluck(:parent_id).compact.uniq

    reset_child_positions(discussion.created_event.id, nil)
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
            descendants.discussion_id = events.discussion_id AND
            descendants.id != events.id AND
            descendants.position_key like CONCAT(events.position_key, '%')
      ), child_count = (
        SELECT count(children.id) FROM events children
        WHERE children.parent_id = events.id AND children.discussion_id IS NOT NULL
      )
      WHERE discussion_id = #{discussion_id.to_i}")

    discussion.created_event.update_child_count
    discussion.created_event.update_descendant_count
    discussion.update_sequence_info!

    # ensure all the discussion_readers have valid read_ranges values
    DiscussionReader.where(discussion_id: discussion_id).each do |reader|
      reader.update_columns(
        read_ranges_string: RangeSet.serialize(
          RangeSet.intersect_ranges(reader.read_ranges, discussion.ranges)
        )
      )
    end

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
          AND   discussion_id IS NOT NULL
        ) AS t
      WHERE events.id = t.id and
            events.position is distinct from t.seq")
    SequenceService.drop_seq!('events_position', parent_id)
  end

  def self.repair_all_threads
    Discussion.pluck(:id).each do |id|
      RepairThreadWorker.perform_async(id)
    end
  end
end
