module Events::Notify::Chatbots
  def trigger!
    super
    GenericWorker.perform_async('ChatbotService', 'publish_event!', id)
  end
end
