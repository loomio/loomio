module TopicItems::Notify::Chatbots
  def trigger!
    super
    PublishChatbotTopicItemWorker.perform_later(id) if notify_chatbots?
  end

  def notify_chatbots?
    true
  end
end
