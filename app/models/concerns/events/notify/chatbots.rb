module Events::Notify::Chatbots
  def trigger!
    super
    PublishChatbotEventWorker.perform_later(id) if notify_chatbots?
  end

  def notify_chatbots?
    true
  end
end
