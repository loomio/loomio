class PublishLiveUpdateTopicItemWorker < ApplicationJob
  def perform(topic_item_id)
    topic_item = TopicItem.find_by(id: topic_item_id)
    return unless topic_item&.itemable
    return if topic_item.itemable.is_a?(Stance) && !topic_item.itemable.shared_update_visible?

    MessageChannelService.publish_topic_models(
      [ topic_item ],
      topic: topic_item.topic,
      group_id: topic_item.itemable.group_id
    )
  end
end
