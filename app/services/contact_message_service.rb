class ContactMessageService
  def self.create(contact_message:, actor:)
    if contact_message.valid?
      BaseMailer.contact_message(
        contact_message.name,
        contact_message.email,
        contact_message.subject,
        contact_message.message,
        {
          site: ENV['CANONICAL_HOST'],
          form_type: 'Support',
          user_id: actor.id
        }.compact
      ).deliver_later
    else
      raise "failed to send a contact message. name: #{contact_message.name}, #{contact_message.email}, #{contact_message.subject}"
    end
  end
end
