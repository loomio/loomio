class EventService
  def self.remove_from_thread(event:, actor:)
    discussion = event.discussion
    raise CanCan::AccessDenied.new unless event.kind == 'discussion_edited'
    actor.ability.authorize! :remove_events, discussion

    event.update(discussion_id: nil)
    discussion.thread_item_destroyed!
    EventBus.broadcast('event_remove_from_thread', event)
    event
  end

  def self.readd_to_thread(kind:)
    Event.where(kind: kind, discussion_id: nil).where("sequence_id is not null").find_each do |event|
      next unless event.eventable

      if Event.exists?(sequence_id: event.sequence_id, discussion_id: event.eventable.discussion_id)
        Event.where(discussion_id: event.eventable.discussion_id)
             .where("sequence_id >= ?", event.sequence_id)
             .order(sequence_id: :desc)
             .each { |event| event.increment!(:sequence_id) }
      end

      event.update_attribute(:discussion_id, event.eventable.discussion_id)
      event.reload.discussion.update_sequence_info!
    end
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

  def self.reposition_events(discussion)
    unless discussion.created_event
      Event.import [Event.new(kind: 'new_discussion',
                              user_id: discussion.author_id,
                              eventable_id: discussion.id,
                              eventable_type: "Discussion",
                              created_at: discussion.created_at)]
      discussion.reload
    end

    items = Event.where(discussion_id: discussion.id).order(:sequence_id)
    items.update_all(parent_id: discussion.created_event.id, position: 0, position_key: nil, depth: 1, child_count: 0)
    items.reload.compact.each(&:set_parent_and_depth!)

    parent_ids = items.pluck(:parent_id).compact.sort.uniq
    Event.where(id: parent_ids).each do |parent_event|
      reorder_with_parent_id(parent_event.id)
      child_count = items.where(parent_id: parent_event.id).count
      parent_event.update_column(:child_count, child_count)
    end

    discussion.created_event.update_child_count
    discussion.update_items_count

    items.reload.each(&:set_position_and_position_key!)
  end

  def self.reorder_with_parent_id(parent_id)
    return unless parent_id
    ActiveRecord::Base.connection.execute(
      "UPDATE events SET position = t.seq
        FROM (
          SELECT id AS id, row_number() OVER(ORDER BY sequence_id) AS seq
          FROM events
          WHERE parent_id = #{parent_id}
          AND   discussion_id IS NOT NULL
        ) AS t
      WHERE events.id = t.id and
            events.position is distinct from t.seq")
  end
end
