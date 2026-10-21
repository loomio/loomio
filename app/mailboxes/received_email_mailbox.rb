class ReceivedEmailMailbox < ApplicationMailbox
  def process
    email = build_received_email

    if !email.is_addressed_to_loomio? || email.is_auto_response?
      Rails.logger.info("Bounced email from #{mail.from}")
      return inbound_email.bounced!
    end

    email, was_created = save_received_email(email)
    return unless email

    attach_files_and_inline_images(email) if was_created
    ReceivedEmailService.route(email, mail: mail)
  rescue => e
    Rails.logger.error("Error processing received email: #{e.class} #{e.message}")
    # Feedback controls future sending. Expose failures to the routing job so
    # they can be retried instead of silently treating them as rejected mail.
    raise if email && EmailFeedbackService.feedback_sender?(email)

    inbound_email.bounced!
  end

  private

  def build_received_email
    headers = mail.header.fields.to_h { |field| [ field.name, field.decoded ] }
    headers.reject! { |name, _| name.casecmp?(EmailFeedbackService::SOURCE_INBOUND_HEADER) }
    email = ReceivedEmail.new(
      message_id: inbound_email.message_id,
      headers: headers,
      body_text: mail.text_part&.decoded || mail.decoded,
      body_html: mail.html_part&.decoded
    )
    if EmailFeedbackService.feedback_sender?(email)
      email.headers[EmailFeedbackService::SOURCE_INBOUND_HEADER] = inbound_email.id
    end
    email
  end

  def save_received_email(email)
    email.save!
    [ email, true ]
  rescue ActiveRecord::RecordNotUnique
    existing = ReceivedEmail.find_by(message_id: email.message_id)
    raise unless existing

    # A previous attempt may have saved the inbound record before feedback
    # processing failed. Resume it; the service atomically records and releases
    # feedback and handles concurrent or repeated reports idempotently.
    if EmailFeedbackService.feedback_sender?(existing) && !existing.released? &&
       existing.header(EmailFeedbackService::SOURCE_INBOUND_HEADER).present?
      return [ existing, false ]
    end

    Rails.logger.info("Ignored duplicate inbound email with Message-ID: #{email.message_id}")
    [ nil, false ]
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
