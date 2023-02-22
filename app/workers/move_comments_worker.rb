class MoveCommentsWorker
  include Sidekiq::Worker
  def perform(event_ids, source_discussion_id, target_discussion_id)
    source_discussion = Discussion.find(source_discussion_id)
    target_discussion = Discussion.find(target_discussion_id)

    # sanitize event_ids (so they cannot be from another discussion), and ensure we have any children
    event_ids = (Event.where(id: event_ids, discussion_id: source_discussion.id).pluck(:id) + 
                Event.where(parent_id: event_ids, discussion_id: source_discussion.id).pluck(:id)).uniq

    all_events = Event.where(id: event_ids)
    all_comments = Comment.where(id: Event.where(id: event_ids, eventable_type: 'Comment').pluck(:eventable_id))
    all_polls = Poll.where(id: Event.where(id: event_ids, eventable_type: 'Poll').pluck(:eventable_id))

    # update eventable.discussion_id
    all_comments.update_all(discussion_id: target_discussion.id)
    all_polls.update_all(discussion_id: target_discussion.id)

    # update comment parents
    all_comments.each do |c|
      if c.parent.discussion_id != target_discussion_id
        c.update_columns(parent_id: target_discussion_id, parent_type: 'Discussion')
      end
    end

    all_events.update(discussion_id: target_discussion_id, sequence_id: nil)

    EventService.repair_thread(target_discussion.id)
    EventService.repair_thread(source_discussion.id)

    ActiveStorage::Attachment.where(record: all_events.map(&:eventable).compact).update_all(group_id: target_discussion.group_id)

    MessageChannelService.publish_models(target_discussion.items, group_id: target_discussion.group.id)
  end
end
