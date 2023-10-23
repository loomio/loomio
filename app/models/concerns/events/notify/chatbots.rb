module Events::Notify::Chatbots
  def trigger!
    super
    GenericWorker.set(wait_until: 30.seconds).perform_async('ChatbotService', 'publish_event!', self.id)
  end
end
