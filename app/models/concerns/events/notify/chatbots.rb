module Events::Notify::Chatbots
  def trigger!
    super
    PublishChatbotEventWorker.perform_later(id)
  end
end
