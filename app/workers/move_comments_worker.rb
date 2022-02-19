class MoveCommentsWorker
  include Sidekiq::Worker
  def perform(ids, source_discussion_id, target_discussion_id)
    source_discussion = Discussion.find(source_discussion_id)
    target_discussion = Discussion.find(target_discussion_id)

    #safe
    safe_ids = Event.where(id: ids, discussion_id: source_discussion.id).pluck(:id)

    # parent events only
    parent_events = Event.where("id in (?)", safe_ids).where(parent_id: source_discussion.created_event.id)

    # children of selected parents
    child_events = Event.where("parent_id in (?)", parent_events.pluck(:id))

    # child events being moved away from their parents
    orphan_events = Event.where("id in (?)", safe_ids).where(eventable_type: 'Comment').where.not(parent_id: parent_events.pluck(:id))

    # strip sequence id from all_events
    # update discussion_id on all_events
    all_events = Event.where(id: [parent_events, child_events, orphan_events].map{|rel| rel.pluck(:id) }.flatten)

    ActiveRecord::Base.transaction do
      # ensure you're not moving events you're not allowed to move
      all_events.update_all(sequence_id: nil,
                            discussion_id: target_discussion.id,
                            parent_id: nil)

      # update comments' parent_id=null (flattening everything)
      Comment.where(id: orphan_events.pluck(:eventable_id)).update_all(parent_id: nil)

      # update discussion_id on eventable i.e. comment to target target_discussion
      Comment.where(id: all_events.where(eventable_type: 'Comment').pluck(:eventable_id)).update_all(discussion_id: target_discussion.id)

      Poll.where(id: all_events.where(eventable_type: 'Poll').pluck(:eventable_id)).update_all(discussion_id: target_discussion.id)
      Poll.where(id: all_events.where(eventable_type: 'Poll').pluck(:eventable_id)).update_all(group_id: target_discussion.group_id)
    end

    EventService.repair_thread(target_discussion.id)
    EventService.repair_thread(source_discussion.id)

    ActiveStorage::Attachment.where(record: all_events.map(&:eventable).compact).update_all(group_id: target_discussion.group_id)

    MessageChannelService.publish_models(target_discussion.items, group_id: target_discussion.group.id)
  end
end
