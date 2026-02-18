class ContactMailer < ActionMailer::Base
  default :from => "\"#{AppConfig.theme[:site_name]}\" <#{ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS}>"

  def contact_message(name, email, subject, body, details = {})
    component = Views::ContactMailer::ContactMessage.new(
      details: details,
      body: body
    )

    mail(
      to: ENV['SUPPORT_EMAIL'],
      reply_to: "\"#{name}\" <#{email}>",
      subject: subject,
    ) do |format|
      format.html { render component }
    end
  end
end
