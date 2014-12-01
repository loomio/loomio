class ContactMessageService
  
  def self.create(contact_message: contact_message, actor: actor)
    contact_message.user = actor
    ContactMessageMailer.delay.contact_message_email contact_message if contact_message.save
  end

end
