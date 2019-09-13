MoveCommentsJob = Struct.new(:ids, :source_discussion, :target_discussion) do
  def perform
    #safe
    safe_ids = Event.where(id: ids, discussion_id: source_discussion.id, eventable_type: 'Comment').pluck(:id)

    # parent events only
    parent_events = Event.where("id in (?)", safe_ids).where(parent_id: source_discussion.created_event.id)

    # children of selected parents
    child_events = Event.where("parent_id in (?)", parent_events.pluck(:id))

    # child events being moved away from their parents
    orphan_events = Event.where("id in (?)", safe_ids).where.not(parent_id: parent_events.pluck(:id))

    # strip sequence id from all_events
    # update discussion_id on all_events
    all_events = Event.where(id: [parent_events, child_events, orphan_events].map{|rel| rel.pluck(:id) }.flatten)

    ActiveRecord::Base.transaction do
      # ensure you're not moving events you're not allowed to move
      all_events.update_all(sequence_id: nil, discussion_id: target_discussion.id)

      # update parent_id on all_events (flattening everything) to target's created event id
      parent_events.update_all(parent_id: target_discussion.created_event.id)
      orphan_events.update_all(parent_id: target_discussion.created_event.id)

      # update depth=1 on all_events (flattening everything)
      orphan_events.update_all(depth: 1)

      # update comments' parent_id=null (flattening everything)
      Comment.where(id: orphan_events.pluck(:eventable_id)).update_all(parent_id: nil)

      # update discussion_id on eventable i.e. comment to target target_discussion
      Comment.where(id: all_events.pluck(:eventable_id)).update_all(discussion_id: target_discussion.id)

      # apply missing sequence ids to all_events
      discussion_max_sequence_id = target_discussion.items.where.not(sequence_id: nil).maximum('sequence_id') || 0
      target_discussion.items.where(sequence_id: nil).order(created_at: :asc).each do |event|
        discussion_max_sequence_id = discussion_max_sequence_id + 1
        event.update(sequence_id: discussion_max_sequence_id)
      end

      # reorder positions of target target_discussion
      Event.reorder_with_parent_id(target_discussion.created_event.id)
      # reorder positions of source_discussion target_discussion
      Event.reorder_with_parent_id(source_discussion.created_event.id)
    end
    # update reader info on target target_discussion
    target_discussion.update_sequence_info!
    # update reader info on source_discussion target_discussion
    source_discussion.update_sequence_info!

    # update items count on target target_discussion
    target_discussion.created_event.update_child_count
    target_discussion.items.each(&:update_child_count)
    target_discussion.update_items_count
    # update items count on source_discussion target_discussion
    source_discussion.created_event.update_child_count
    source_discussion.update_items_count
    source_discussion.items.each(&:update_child_count)
  end
end
