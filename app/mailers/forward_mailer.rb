class ForwardMailer < ActionMailer::Base
  layout nil

  def forward_message(to:, from:, reply_to:, subject:, body_text: nil, body_html: nil)
    @body_text = body_text
    @body_html = body_html
    mail(
      from: from,
      to: to,
      reply_to: reply_to,
      subject: subject,
      layout: nil
    )
  end
end
