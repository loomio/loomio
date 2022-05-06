module Events::Notify::Chatbots
  def trigger!
    super
    ChatbotService.delay.publish_event!(self.id)
  end
end
