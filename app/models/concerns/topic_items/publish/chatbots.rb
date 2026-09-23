module TopicItems::Publish::Chatbots
  extend ActiveSupport::Concern

  included do
    after_create_commit :enqueue_chatbot_publication!
  end

  def enqueue_chatbot_publication!
    PublishChatbotTopicItemWorker.perform_later(id) if publish_to_chatbots?
  end

  def publish_to_chatbots?
    true
  end
end
