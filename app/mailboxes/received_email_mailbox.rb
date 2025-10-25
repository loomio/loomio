class ReceivedEmailMailbox < ApplicationMailbox
  def process
    email = build_received_email

    if email.is_addressed_to_loomio? && !email.is_auto_response?
      email.save!
      ReceivedEmailService.route(email)
    else
      inbound_email.bounced!
    end
  end

  private

  def build_received_email
    email = ReceivedEmail.new(
      headers: mail.header.fields.map {|f| [f.name, f.value] }.to_h,
      body_text: (mail.text_part&.decoded || mail.decoded),
      body_html: mail.html_part&.decoded
    )

    email.attachments = mail.attachments.each do |a|
      {
        io: StringIO.new(a.decoded),
        content_type: a.content_type,
        filename: a.filename
      }
    end

    email
  end
end
