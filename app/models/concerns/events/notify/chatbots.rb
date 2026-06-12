module Events::Notify::Chatbots
  def trigger!
    super
    GenericWorker.perform_later('ChatbotService', 'publish_event!', id)
  end
end
