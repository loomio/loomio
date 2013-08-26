class EmailTemplateMailer < BaseMailer
  def basic(email)
    @email = email
    mail(to: email.to,
         from: email.from,
         reply_to: email.reply_to,
         subject: email.subject)
  end
end
