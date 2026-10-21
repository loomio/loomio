# Forwarded email feedback contains a delivery-status/feedback report and the
# original message headers. Match the original Message-ID, never just an address
# or subject, so another email to the same person cannot inherit the failure.
# Haraka removes sender-supplied Authentication-Results before stamping its own.
class EmailFeedbackService
  SOURCE_INBOUND_HEADER = 'X-Loomio-Inbound-Email-Id'.freeze
  REPORT_TYPES = %w[message/delivery-status message/feedback-report message/rfc822 text/rfc822-headers].freeze

  def self.feedback_sender?(email)
    email.is_bounce? || email.is_complaint? ||
      email.sender_email.to_s.match?(/\Amailer-daemon@(?:[a-z0-9-]+\.)*amazonses\.com\z/i)
  end

  def self.process(email, mail: nil)
    new(email, mail).process
  end

  def initialize(email, mail)
    @email = email
    @mail = mail
  end

  def process
    return false unless self.class.feedback_sender?(@email)
    # Consume untrusted purported feedback without replying or mutating a user.
    unless authenticated?
      @email.update!(released: true)
      return true
    end

    parts = report_parts
    status_reports = parts.select { |type, _| type == 'message/delivery-status' }.map(&:last)
    complaint_reports = parts.select { |type, _| type == 'message/feedback-report' }.map(&:last)
    originals = parts.select { |type, _| %w[message/rfc822 text/rfc822-headers].include?(type) }
    message_ids = originals.filter_map { |_, text| Mail.read_from_string(text).message_id }.uniq
    source_message = message_ids.any? ? message_ids.sort.join("\n") : (@email.message_id || @email.id).to_s
    source_digest = Digest::SHA256.hexdigest(source_message)
    deliveries = NotificationDelivery.where(channel: 'email').where(email_message_id: message_ids)
      .or(NotificationDelivery.where(channel: 'email', provider_message_id: message_ids.map { |id| id.split('@').first }))
      .includes(:recipient)
    # A DSN can contain a different result for each recipient. Classify each
    # recipient block separately so one permanent bounce cannot block others.
    reports = status_reports.flat_map { |report| report.split(/\r?\n\r?\n/) }.filter_map do |report|
      addresses = report_addresses(report)
      next if addresses.empty? && !report.match?(/^(?:Action|Status):/i)

      delayed = report.match?(/^Action:\s*delayed\s*$/i)
      bounce_type = if report.match?(/^Status:\s*5\./i)
        'Permanent'
      elsif report.match?(/^Status:\s*4\./i)
        'Transient'
      else
        'Undetermined'
      end
      { addresses: addresses, kind: delayed ? 'delayed' : 'bounced',
        bounce_type: delayed ? nil : bounce_type, detail: report_detail(report) }
    end
    complaint_reports.each do |report|
      reports << { addresses: report_addresses(report), kind: 'complained', detail: report_detail(report) }
    end
    if reports.empty? && @email.is_complaint?
      reports << { addresses: [], kind: 'complained' }
    end

    ReceivedEmail.transaction do
      @email.lock!
      return true if @email.released?

      reports.each do |report|
        addresses = report.fetch(:addresses)
        # With no saved destination, explicit recipients link only while the
        # account still uses that address. Old addresses can be blocked below.
        matched = deliveries.filter_map do |delivery|
          address = addresses.find { |recipient| recipient.casecmp?(delivery.recipient.email.to_s) }
          [delivery, address] if addresses.empty? || address
        end
        matched.each do |delivery, address|
          NotificationEmailEventService.record!(delivery: delivery, kind: report.fetch(:kind),
            source_key: "email:#{@email.message_id || @email.id}:#{report.fetch(:kind)}",
            occurred_at: @email.created_at, detail: report[:detail], bounce_type: report[:bounce_type],
            recipient_address: address)
        end

        if addresses.empty?
          Rails.logger.warn("Email feedback recipient not identified: received_email_id=#{@email.id} kind=#{report.fetch(:kind)}")
        end

        # Older mail may have no tracked delivery. Retain authenticated address
        # evidence without pretending that it belongs to a particular invitation.
        reason = EmailSuppressionService.reason_for(kind: report.fetch(:kind), bounce_type: report[:bounce_type])
        next unless reason

        addresses -= matched.filter_map(&:last)
        addresses.each do |address|
          EmailSuppressionService.record!(email: address, reason: reason,
            source_key: "feedback:#{source_digest}:#{reason}:#{EmailSuppression.address_digest(address)}",
            occurred_at: @email.created_at)
        end
      end
      @email.update!(released: true)
    end
    true
  end

  private

  def report_addresses(report)
    # DSNs carry an address type; SES ARF complaints also use a bare recipient.
    dsn = report.scan(/^(?:Final-Recipient|Original-Recipient):\s*rfc822;\s*([^\s<>]+@[^\s<>]+)\s*$/i)
    arf = report.scan(/^Original-Rcpt-To:\s*(?:rfc822;\s*)?<?([^\s<>]+@[^\s<>]+)>?\s*$/i)
    (dsn + arf).flatten.uniq
  end

  def report_detail(report)
    report.scan(/^(?:Diagnostic-Code|Status|Feedback-Type):\s*(.+)$/i).flatten.join("\n").truncate(2000).presence
  end

  def authenticated?
    results = @email.header('authentication-results').to_s
    hostname = @email.sender_hostname
    domain = Regexp.escape(hostname.match?(/(?:\A|\.)amazonses\.com\z/i) ? 'amazonses.com' : hostname)
    results.split(';').any? do |result|
      result.match?(/\bdkim=pass\b/i) &&
        result.match?(/\bheader\.(?:d|i)=(?:[^\s;@]*@)?(?:[a-z0-9-]+\.)*#{domain}(?:\s|\z)/i)
    end
  end

  def report_parts
    # The mailbox stamps this private reference after discarding sender-supplied
    # copies. On retry, pair the saved authentication headers with the exact raw
    # report they authenticated, never a new body sharing the same Message-ID.
    if inbound_id = @email.header(SOURCE_INBOUND_HEADER)
      inbound = ActionMailbox::InboundEmail.find(inbound_id)
      raise 'Feedback source Message-ID mismatch' unless inbound.message_id == @email.message_id

      @mail = inbound.mail
    end
    if @mail
      # Only the outer report parts describe this feedback. Attached messages
      # inside the original email must not contribute other delivery identities.
      @mail.parts.select { |part| REPORT_TYPES.include?(part.mime_type) }.map { |part| [ part.mime_type, part.body.decoded ] }
    else
      @email.attachments.filter_map do |attachment|
        [ attachment.content_type, attachment.download ] if REPORT_TYPES.include?(attachment.content_type)
      end
    end
  end
end
