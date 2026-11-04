module InboundEmailHelper
  def build_inbound_email(headers: {}, body_text: nil, body_html: nil, message_id: nil)
    mail = Mail.new
    headers.each { |name, value| mail[name] = value }
    mail.message_id = message_id || "#{SecureRandom.uuid}@inbound.test"
    if body_html
      mail.text_part = Mail::Part.new(content_type: 'text/plain; charset=UTF-8', body: body_text.to_s)
      mail.html_part = Mail::Part.new(content_type: 'text/html; charset=UTF-8', body: body_html)
    else
      mail.body = body_text.to_s
    end
    store_inbound_mail(mail)
  end

  def store_inbound_mail(mail)
    ActionMailbox::InboundEmail.create_and_extract_message_id!(mail.encoded, status: :processing)
  end

  def create_pending_email(group:, **attributes)
    inbound = build_inbound_email(**attributes)
    inbound.update!(processing_completed_at: Time.current, status: :delivered)
    PendingEmail.create!(group: group, inbound_email: inbound)
  end
end
