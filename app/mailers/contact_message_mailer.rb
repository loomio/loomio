class ContactMessageMailer < BaseMailer
  default :to => "contact@loomio.org"
  def contact_message_email(contact_message)
    @name = contact_message.name
    @email = contact_message.email
    @message = contact_message.message
    @user_id = contact_message.user_id
    mail(from: "#{@name} <#{@email}>", subject: "Enquiry - #{@name}")
  end
end
