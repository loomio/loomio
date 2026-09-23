class PublishLiveUpdateTopicItemWorker < ApplicationJob
  def perform(topic_item_id)
    topic_item = TopicItem.find_by(id: topic_item_id)
    return unless topic_item&.itemable
    return if topic_item.itemable.is_a?(Stance) && !topic_item.itemable.shared_update_visible?

    if topic_item.itemable.group_id
      MessageChannelService.publish_models([ topic_item ], group_id: topic_item.itemable.group_id)
    end
    if topic_item.itemable.respond_to?(:topic)
      topic_item.itemable.topic.guests.find_each do |user|
        MessageChannelService.publish_models([ topic_item ], user_id: user.id)
      end
    end
  end
end
