# Forwarded SES feedback contains a delivery-status/feedback report and the
# original message headers. Match the original Message-ID, never just an address
# or subject, so another email to the same person cannot inherit the failure.
# Haraka removes sender-supplied Authentication-Results before stamping its own.
class EmailFeedbackService
  REPORT_TYPES = %w[message/delivery-status message/feedback-report message/rfc822 text/rfc822-headers].freeze

  def self.process(email, mail: nil)
    new(email, mail).process
  end

  def initialize(email, mail)
    @email = email
    @mail = mail
  end

  def process
    return false unless feedback_sender?
    # Consume untrusted purported feedback without replying or mutating a user.
    unless authenticated?
      @email.update!(released: true)
      return true
    end

    parts = report_parts
    status_reports = parts.select { |type, _| type == 'message/delivery-status' }.map(&:last)
    complaint_reports = parts.select { |type, _| type == 'message/feedback-report' }.map(&:last)
    kind = if complaint_reports.any? || @email.is_complaint?
      'complained'
    elsif status_reports.any? { |report| report.match?(/^Action:\s*delayed\s*$/i) }
      'delayed'
    else
      'bounced'
    end
    originals = parts.select { |type, _| %w[message/rfc822 text/rfc822-headers].include?(type) }
    message_ids = originals.filter_map { |_, text| Mail.read_from_string(text).message_id }.uniq
    deliveries = NotificationDelivery.where(channel: 'email').where(email_message_id: message_ids)
      .or(NotificationDelivery.where(channel: 'email', provider_message_id: message_ids.map { |id| id.split('@').first }))
    addresses = (status_reports + complaint_reports).flat_map do |report|
      report.scan(/^(?:Final-Recipient|Original-Recipient):\s*rfc822;\s*([^\s<>]+@[^\s<>]+)\s*$/i).flatten
    end.uniq
    detail = (status_reports + complaint_reports).flat_map do |report|
      report.scan(/^(?:Diagnostic-Code|Status|Feedback-Type):\s*(.+)$/i).flatten
    end.join("\n").truncate(2000)

    ReceivedEmail.transaction do
      @email.lock!
      return true if @email.released?

      deliveries.each do |delivery|
        next if addresses.any? && !addresses.any? { |address| address.casecmp?(delivery.email_address) }

        NotificationEmailEventService.record!(delivery: delivery, kind: kind,
          source_key: "email:#{@email.message_id || @email.id}:#{kind}", occurred_at: @email.created_at, detail: detail.presence)
      end

      # Preserve the existing suppression policy until address suppression has
      # replaced the counters. Delays are not permanent failures.
      if %w[bounced complained].include?(kind)
        addresses -= deliveries.pluck(:email_address)
        addresses = [ @email.bounced_or_complained_address ].compact if addresses.empty? && message_ids.empty?
        column = kind == 'bounced' ? 'bounces_count' : 'complaints_count'
        User.where(email: addresses).update_all("#{column} = #{column} + 1") if addresses.any?
      end
      @email.update!(released: true)
    end
    true
  end

  private

  def feedback_sender?
    @email.is_bounce? || @email.is_complaint? ||
      @email.sender_email.to_s.match?(/\Amailer-daemon@(?:[a-z0-9-]+\.)*amazonses\.com\z/i)
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
    @mail ||= ActionMailbox::InboundEmail.find_by(message_id: @email.message_id)&.mail if @email.message_id
    if @mail
      @mail.all_parts.select { |part| REPORT_TYPES.include?(part.mime_type) }.map { |part| [ part.mime_type, part.body.decoded ] }
    else
      @email.attachments.filter_map do |attachment|
        [ attachment.content_type, attachment.download ] if REPORT_TYPES.include?(attachment.content_type)
      end
    end
  end
end
