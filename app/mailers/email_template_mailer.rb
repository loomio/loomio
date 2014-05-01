class EmailTemplateMailer < ActionMailer::Base
  include ApplicationHelper
  include LocalesHelper
  include ERB::Util
  include ActionView::Helpers::TextHelper

  default :from => "Loomio <noreply@loomio.org>", :css => :email

  def basic(email)
    headers "X-SMTPAPI" => {
      category: ["EmailTemplate", email.email_template.name],
    }.to_json

    @email = email
    mail(to: email.to,
         from: email.from,
         reply_to: email.reply_to,
         subject: email.subject)
  end
end
