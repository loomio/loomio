class ContactMessageMailer < BaseMailer
  default :to => "contact@loomio.org"
  def contact_message_email(contact_message)
    @email = contact_message.email
    @name = contact_message.name
    @message = contact_message.message
    @user_id = contact_message.user_id
    @destination = contact_message.destination + '@' + ENV.fetch('CANONICAL_HOST')
    mail(from: "#{@name} <#{@email}>", to: @destination, subject: "Enquiry - #{@name}")
  end
end
