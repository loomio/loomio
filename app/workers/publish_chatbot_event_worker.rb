class PublishChatbotEventWorker < ApplicationJob
  def perform(event_id)
    ChatbotService.publish_event!(event_id)
  end
end
