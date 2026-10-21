# Track a rendered notification around Action Mailer's delivery callback. Save
# correlation IDs before SMTP, and commit success with its history event. Recipient
# locks prevent completion from restoring identifiers erased by account redaction;
# the network call stays outside those transactions.
class NotificationEmailDelivery
  def initialize(delivery, message)
    @delivery = delivery
    @message = message
  end

  def deliver
    if @message.to.blank? || !@message.perform_deliveries
      record_skipped
      return @message
    end
    return @message unless prepare

    result = yield
    record_sent
    result
  rescue Net::SMTPFatalError, Net::SMTPServerBusy => error
    NotificationEmailEventService.record!(delivery: @delivery,
      kind: error.is_a?(Net::SMTPFatalError) ? 'rejected' : 'delayed',
      source_key: "smtp:#{SecureRandom.uuid}", occurred_at: Time.current, detail: error.message.truncate(2000))
    raise
  end

  private

  def record_skipped
    @delivery.events.find_or_create_by!(source_key: 'application:skipped') do |event|
      event.kind = 'skipped'
      event.occurred_at = Time.current
    end
  end

  def prepare
    @delivery.recipient.with_lock do
      return false if @delivery.recipient.email.nil?

      @message.message_id = @delivery.email_message_id || "#{SecureRandom.uuid}@#{ENV.fetch('SMTP_DOMAIN')}"
      @delivery.update!(email_message_id: @message.message_id)
    end
    if @message.delivery_method.is_a?(Mail::SMTP)
      @message.delivery_method(NotificationSmtpDelivery, @message.delivery_method.settings)
    end
    true
  end

  def record_sent
    transport = @message.delivery_method
    provider_message_id = transport.provider_message_id if transport.is_a?(NotificationSmtpDelivery)
    @delivery.recipient.with_lock do
      return if @delivery.recipient.email.nil?

      @delivery.update!(delivered_at: Time.current, provider_message_id: provider_message_id)
      @delivery.events.create!(kind: 'sent', source_key: "application:sent:#{@message.message_id}",
        occurred_at: @delivery.delivered_at)
    end
  end
end
