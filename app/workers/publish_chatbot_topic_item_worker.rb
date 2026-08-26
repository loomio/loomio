class PublishChatbotTopicItemWorker < ApplicationJob
  def perform(topic_item_id)
    ChatbotService.publish_topic_item!(topic_item_id)
  end
end
