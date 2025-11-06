class ForwardMailer < ActionMailer::Base
  layout nil
  default :from => "\"#{AppConfig.theme[:site_name]}\" <#{BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS}>"

  def forward_message(to:, from:, reply_to:, subject:, body_text: nil, body_html: nil)
    @body_text = body_text
    @body_html = body_html
    mail(
      from: from,
      to: to,
      reply_to: reply_to,
      subject: subject,
      layout: nil,
      skip_premailer: true
    )
  end



  def bounce(to:)
    headers['Auto-Submitted'] = 'auto-replied'
    headers['X-Precedence'] = 'auto_reply'
    headers['X-Auto-Response-Suppress'] = 'All'

    mail(
      to: to,
      subject: I18n.t('forward_mailer.bounce.subject'),
    )
  end
end
