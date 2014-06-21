class ContactMessageMailer < BaseMailer
  default :to => "#{ENV["INTERCOM_APP_ID"]}@incoming.intercom.io"
  def contact_message_email(contact_message)
    @email = contact_message.email
    @name = contact_message.name
    @message = contact_message.message
    @user_id = contact_message.user_id
    mail(from: "#{@name} <#{@email}>", subject: "Enquiry - #{@name}")
  end
end
