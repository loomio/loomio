class ContactMessageService

  def self.create(contact_message:, actor:)
    contact_message.user = actor
    ContactMessageMailer.delay(priority: 2).contact_message_email contact_message if contact_message.save
  end

end
