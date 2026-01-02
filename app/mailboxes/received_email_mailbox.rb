class ReceivedEmailMailbox < ApplicationMailbox
  def process
    email = build_received_email

    if !email.is_addressed_to_loomio? || email.is_auto_response?
      Rails.logger.info("Bounced email from #{mail.from}")
      return inbound_email.bounced!
    end

    email.save!
    attach_files_and_inline_images(email)
    ReceivedEmailService.route(email)
  rescue => e
    Rails.logger.error("Error processing received email: #{e.class} #{e.message}")
    inbound_email.bounced!
  end

  private

  def build_received_email
    ReceivedEmail.new(
      headers:   mail.header.fields.to_h { |f| [f.name, f.decoded] },
      body_text: mail.text_part&.decoded || mail.decoded,
      body_html: mail.html_part&.decoded
    )
  end

  def attach_files_and_inline_images(email)
    return unless mail.attachments.present?

    cid_map = {}

    mail.attachments.each do |a|
      io = StringIO.new(a.decoded)
      io.set_encoding(Encoding::BINARY)
      attachment = email.attachments.attach(
        io: io,
        filename: a.filename || a.cid,
        content_type: a.mime_type,
        identify: false
      ).first

      # Map content ID → ActiveStorage URL for inline replacements
      if a.inline? && a.cid.present?
        cid_map[a.cid.gsub(/[<>]/, '')] = Rails.application.routes.url_helpers.rails_blob_url(
          attachment.blob,
          only_path: true
        )
      end
    end

    # Replace inline image references (cid:xxxx) with actual blob URLs
    if email.body_html.present? && cid_map.any?
      updated_html = email.body_html.dup
      cid_map.each do |cid, url|
        updated_html.gsub!("cid:#{cid}", url)
      end
      email.update!(body_html: updated_html)
    end
  end
end
