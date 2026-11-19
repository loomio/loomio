class ForwardMailer < ApplicationMailer
  self.delivery_job = InboundEmailDeliveryJob
  layout nil
  default :from => "\"#{AppConfig.theme[:site_name]}\" <#{ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS}>"

  def bounce(to:)
    headers['Auto-Submitted'] = 'auto-replied'
    headers['X-Precedence'] = 'auto_reply'
    headers['X-Auto-Response-Suppress'] = 'All'

    mail(
      to: to,
      subject: I18n.t('forward_mailer.bounce.subject'),
    )
  end

  def comment_rejected(to:, topic:, validation_messages:)
    headers['Auto-Submitted'] = 'auto-replied'
    headers['X-Precedence'] = 'auto_reply'
    headers['X-Auto-Response-Suppress'] = 'All'

    component = Views::ForwardMailer::CommentRejected.new(topic: topic, validation_messages: validation_messages)

    send_email(to: to, locale: :en, component: component) {
      I18n.t('forward_mailer.comment_rejected.subject')
    }
  end
end
