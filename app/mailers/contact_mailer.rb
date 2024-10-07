class ContactMailer < ActionMailer::Base
  default :from => "\"#{AppConfig.theme[:site_name]}\" <#{BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS}>"

  def contact_message(name, email, subject, body, details = {})
    @details = details
    @body = body
    mail(
      to: ENV['SUPPORT_EMAIL'],
      reply_to: "\"#{name}\" <#{email}>",
      subject: subject,
    )
  end
end
