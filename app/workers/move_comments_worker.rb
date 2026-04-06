class MoveCommentsWorker
  include Sidekiq::Worker
  def perform(event_ids, source_topic_id, target_topic_id)
    source_topic = Topic.find(source_topic_id)
    target_topic = Topic.find(target_topic_id)

    # sanitize event_ids (so they cannot be from another topic), and ensure we have any children
    event_ids = Event.where(id: event_ids, topic_id: source_topic.id).pluck(:id)
    event_ids = all_event_ids(event_ids, source_topic.id)

    all_events = Event.where(id: event_ids)
    all_comments = Comment.where(id: Event.where(id: event_ids, eventable_type: 'Comment').pluck(:eventable_id))
    all_polls = Poll.where(id: Event.where(id: event_ids, eventable_type: 'Poll').pluck(:eventable_id))

    # update polls to point to target topic
    all_polls.update_all(topic_id: target_topic.id)

    # update comment parents if they pointed to the source topicable
    target_topicable = target_topic.topicable
    all_comments.each do |c|
      if c.parent_type == source_topic.topicable_type && c.parent_id == source_topic.topicable_id
        c.update_columns(parent_id: target_topicable.id, parent_type: target_topicable.class.name)
      end
    end

    all_events.update_all(topic_id: target_topic.id, sequence_id: nil)

    TopicService.repair_thread(target_topic.id)
    TopicService.repair_thread(source_topic.id)

    SearchService.reindex_by_discussion_id(target_topicable.id) if target_topicable.is_a?(Discussion)
    SearchService.reindex_by_discussion_id(source_topic.topicable_id) if source_topic.topicable_type == 'Discussion'

    ActiveStorage::Attachment.where(record: all_events.map(&:eventable).compact).update_all(group_id: target_topic.group_id)

    MessageChannelService.publish_models(target_topic.items, group_id: target_topic.group_id)
  end

  def all_event_ids(root_ids, topic_id)
    all_ids = find_child_ids(root_ids, topic_id)
    if all_ids.length == root_ids.length
      all_ids
    else
      all_event_ids(all_ids, topic_id)
    end
  end

  def find_child_ids(ids, topic_id)
    ids += Event.where(topic_id: topic_id, parent_id: ids).pluck(:id)
    ids.uniq.sort
  end
end
