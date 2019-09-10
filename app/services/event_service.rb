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

  def self.move_events(discussion:, actor:, params:)
    events = Event.where(eventable_type: 'Comment', id: Array(params[:forked_event_ids]).compact)
    source = events.first.discussion

    actor.ability.authorize! :move_events, discussion
    actor.ability.authorize! :move_events, source

    # strip sequence id from events
    events.update_all(sequence_id: nil)

    # update discussion_id on events
    events.update_all(discussion_id: discussion.id)

    # update parent_id on events (flattening everything) to target's created event id
    events.update_all(parent_id: discussion.created_event.id)

    # update depth=1 on events (flattening everything)
    events.update_all(depth: 1)

    # update comments' parent_id=null (flattening everything)
    comments = Comment.where(id: events.pluck(:eventable_id))
    comments.update_all(parent_id: nil)

    # update discussion_id on eventable i.e. comment to target discussion
    comments.update_all(discussion_id: discussion.id)

    # reorder positions
    Event.reorder_with_parent_id(discussion.created_event.id)
    Event.reorder_with_parent_id(source.created_event.id)

    # apply missing sequence ids to events
    discussion_max_sequence_id = discussion.items.where.not(sequence_id: nil).maximum('sequence_id') || 0

    events.order(created_at: :asc).each do |event|
      discussion_max_sequence_id = discussion_max_sequence_id + 1
      event.update(sequence_id: discussion_max_sequence_id)
    end

    # update sequence info on target discussion
    discussion.update_sequence_info!
    # update sequence info on source discussion
    source.update_sequence_info!
    # update items count on target discussion
    discussion.update_items_count
    # update items count on source discussion
    source.update_items_count
    # rename to move_comments

    # Events::DiscussionForked.publish!(event.eventable, source)
  end

end
