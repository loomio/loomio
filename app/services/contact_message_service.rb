class ContactMessageService
  def self.create(contact_message:, actor:)
    contact_message.save

    EventBus.broadcast('contact_message_create', contact_message, actor)
  end
end
