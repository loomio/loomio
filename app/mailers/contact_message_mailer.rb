class ContactMessageMailer < BaseMailer
  default :to => "contact@loomio.org"
  def contact_message_email(contact_message)
    @name = contact_message.name
    @email = contact_message.email
    @message = contact_message.message
    @user_id = contact_message.user_id
    @destination = contact_message.destination
    mail(from: "#{@name} <#{@email}>", to: @destination, subject: "Enquiry - #{@name}")
  end
end
