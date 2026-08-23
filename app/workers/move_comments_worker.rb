class MoveCommentsWorker < ApplicationJob
  def perform(topic_item_ids, source_topic_id, target_topic_id, actor_id = nil)
    source_topic = Topic.find(source_topic_id)
    target_topic = Topic.find(target_topic_id)

    # sanitize topic_item_ids (so they cannot be from another topic), and ensure we have any children
    topic_item_ids = TopicItem.where(id: topic_item_ids, topic_id: source_topic_id).pluck(:id)
    topic_item_ids = all_topic_item_ids(topic_item_ids, source_topic_id)

    all_topic_items = TopicItem.where(id: topic_item_ids)
    all_comments = Comment.where(id: TopicItem.where(id: topic_item_ids, itemable_type: 'Comment').pluck(:itemable_id))
    all_polls = Poll.where(id: TopicItem.where(id: topic_item_ids, itemable_type: 'Poll').pluck(:itemable_id))

    # update polls to point to target topic
    all_polls.update_all(topic_id: target_topic_id)

    # reparent comments whose parent is not also being moved
    target_topicable = target_topic.topicable
    moved_itemable_ids = all_topic_items.pluck(:itemable_type, :itemable_id).map { |t, id| [t, id] }
    all_comments.each do |c|
      unless moved_itemable_ids.include?([c.parent_type, c.parent_id])
        c.update_columns(parent_id: target_topicable.id, parent_type: target_topicable.class.name)
      end
    end

    all_topic_items.update_all(topic_id: target_topic_id, sequence_id: nil)

    TopicService.repair(target_topic_id)
    source_topic.update(discarded_at: Time.now, discarded_by: actor_id) if source_topic.topicable_type == 'Poll' &&
                                                                           all_polls.exists?(source_topic.topicable_id) &&
                                                                           !TopicItem.exists?(topic_id: source_topic_id)
    TopicService.repair(source_topic_id)

    SearchService.reindex_by_discussion_id(target_topicable.id) if target_topicable.is_a?(Discussion)
    SearchService.reindex_by_discussion_id(source_topic.topicable_id) if source_topic.topicable_type == 'Discussion'

    ActiveStorage::Attachment.where(record: all_topic_items.map(&:itemable).compact).update_all(group_id: target_topic.group_id)

    MessageChannelService.publish_models([source_topic], group_id: source_topic.group_id)
    MessageChannelService.publish_models([target_topic], group_id: target_topic.group_id)
    MessageChannelService.publish_models(target_topic.items, group_id: target_topic.group_id)
  end

  def all_topic_item_ids(root_ids, topic_id)
    all_ids = find_child_ids(root_ids, topic_id)
    if all_ids.length == root_ids.length
      all_ids
    else
      all_topic_item_ids(all_ids, topic_id)
    end
  end

  def find_child_ids(ids, topic_id)
    ids += TopicItem.where(topic_id: topic_id, parent_id: ids).pluck(:id)
    ids.uniq.sort
  end
end
