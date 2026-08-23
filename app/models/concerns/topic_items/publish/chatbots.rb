module TopicItems::Publish::Chatbots
  def trigger!
    super
    PublishChatbotTopicItemWorker.perform_later(id) if publish_to_chatbots?
  end

  def publish_to_chatbots?
    true
  end
end
