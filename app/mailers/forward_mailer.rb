class ForwardMailer < ApplicationMailer
  layout nil
  default :from => "\"#{AppConfig.theme[:site_name]}\" <#{ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS}>"

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
    ) do |format|
      format.text { render 'forward_message' } if body_text.present?
      format.html { render 'forward_message' } if body_html.present?
    end
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

  def comment_rejected(to:, comment:)
    headers['Auto-Submitted'] = 'auto-replied'
    headers['X-Precedence'] = 'auto_reply'
    headers['X-Auto-Response-Suppress'] = 'All'

    component = Views::ForwardMailer::CommentRejected.new(comment: comment)

    send_email(to: to, locale: :en, component: component) {
      I18n.t('forward_mailer.comment_rejected.subject')
    }
  end
end
