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

    ActiveRecord::Base.transaction do
      # ensure you're not moving events you're not allowed to move
      unsafe_ids = Array(params[:forked_event_ids]).compact
      source = Event.find(unsafe_ids.first).discussion

      actor.ability.authorize! :move_comments, source
      actor.ability.authorize! :move_comments, discussion

      #safe
      safe_ids = Event.where(id: unsafe_ids, discussion_id: source.id, eventable_type: 'Comment').pluck(:id)

      # parent events only
      parent_events = Event.where("id in (?)", safe_ids).where(parent_id: source.created_event.id)

      # children of selected parents
      child_events = Event.where("parent_id in (?)", parent_events.pluck(:id))

      # child events being moved away from their parents
      orphan_events = Event.where("id in (?)", safe_ids).where.not(parent_id: parent_events.pluck(:id))

      # strip sequence id from all_events
      # update discussion_id on all_events
      all_events = Event.where(id: [parent_events, child_events, orphan_events].map{|rel| rel.pluck(:id) }.flatten)
      all_events.update_all(sequence_id: nil, discussion_id: discussion.id)

      # update parent_id on all_events (flattening everything) to target's created event id
      parent_events.update_all(parent_id: discussion.created_event.id)
      orphan_events.update_all(parent_id: discussion.created_event.id)

      # update depth=1 on all_events (flattening everything)
      orphan_events.update_all(depth: 1)

      # update comments' parent_id=null (flattening everything)
      Comment.where(id: orphan_events.pluck(:eventable_id)).update_all(parent_id: nil)

      # update discussion_id on eventable i.e. comment to target discussion
      Comment.where(id: all_events.pluck(:eventable_id)).update_all(discussion_id: discussion.id)

      # apply missing sequence ids to all_events
      discussion_max_sequence_id = discussion.items.where.not(sequence_id: nil).maximum('sequence_id') || 0
      discussion.items.where(sequence_id: nil).order(created_at: :asc).each do |event|
        discussion_max_sequence_id = discussion_max_sequence_id + 1
        event.update(sequence_id: discussion_max_sequence_id)
      end

      # reorder positions of target discussion
      Event.reorder_with_parent_id(discussion.created_event.id)
      # reorder positions of source discussion
      Event.reorder_with_parent_id(source.created_event.id)

      # update reader info on target discussion
      discussion.update_sequence_info!
      # update reader info on source discussion
      source.update_sequence_info!

      # update items count on target discussion
      discussion.created_event.update_child_count
      discussion.items.each(&:update_child_count)
      discussion.update_items_count
      # update items count on source discussion
      source.created_event.update_child_count
      source.update_items_count
      source.items.each(&:update_child_count)
    end
  end
end
