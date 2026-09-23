class ContactMessageService
  def self.create(contact_message:, actor:)
    return contact_message unless contact_message.valid?

    ContactMailer.contact_message(
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
    contact_message
  end
end
