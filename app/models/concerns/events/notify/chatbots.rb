module Events::Notify::Chatbots
  def trigger!
    super
    ChatbotService.publish_event!(self)
  end
end
