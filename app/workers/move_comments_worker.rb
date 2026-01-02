class MoveCommentsWorker
  include Sidekiq::Worker
  def perform(event_ids, source_discussion_id, target_discussion_id)
    source_discussion = Discussion.find(source_discussion_id)
    target_discussion = Discussion.find(target_discussion_id)

    # sanitize event_ids (so they cannot be from another discussion), and ensure we have any children
    event_ids = Event.where(id: event_ids, discussion_id: source_discussion.id).pluck(:id)
    event_ids = all_event_ids(event_ids, source_discussion.id)

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

    EventService.repair_discussion(target_discussion.id)
    EventService.repair_discussion(source_discussion.id)

    SearchService.reindex_by_discussion_id(target_discussion.id)
    SearchService.reindex_by_discussion_id(source_discussion.id)

    ActiveStorage::Attachment.where(record: all_events.map(&:eventable).compact).update_all(group_id: target_discussion.group_id)

    MessageChannelService.publish_models(target_discussion.items, group_id: target_discussion.group.id)
  end

  def all_event_ids(root_ids, discussion_id)
    all_ids = find_child_ids(root_ids, discussion_id)
    if all_ids.length == root_ids.length
      all_ids
    else
      all_event_ids(all_ids, discussion_id)
    end
  end

  def find_child_ids(ids, discussion_id)
    ids += Event.where(discussion_id: discussion_id, parent_id: ids).pluck(:id)
    ids.uniq.sort
  end
end
