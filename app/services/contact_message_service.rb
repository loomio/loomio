class ContactMessageService
  def self.create(contact_message:, actor:)
    client = Clients::OsTicket.new if ENV['OS_TICKET_HOST']
    client = Clients::Zammad.new if ENV['ZAMMAD_HOST']
    if client && contact_message.valid?
      request = client.post_message(contact_message.name,
                                    contact_message.email,
                                    contact_message.subject,
                                    contact_message.message)
      EventBus.broadcast('contact_message_create', contact_message, actor)
    else
      raise "failed to send a contact message. name: #{contact_message.name}, #{contact_message.email}, #{contact_message.subject}"
    end
  end
end
