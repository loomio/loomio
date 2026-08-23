class PublishTopicItemWorker < ApplicationJob
  def perform(topic_item_id)
    return unless TopicItem.exists?(id: topic_item_id)
    TopicItem.sti_find(topic_item_id).trigger!
  end
end
