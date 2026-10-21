# Deliver the email row assigned to this job. Solid Queue owns retry and failure history.
class DeliverNotificationEmailWorker < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(notification_delivery_id)
    delivery = NotificationDelivery.find_by(id: notification_delivery_id, channel: "email")
    return unless delivery
    return if delivery.delivered_at?
    return unless NotificationService.group_enabled?(delivery.notification.subject)

    mailer = NotificationMailer.notification(delivery.id)
    message = mailer.message
    if message.to.blank? || !message.perform_deliveries
      delivery.events.find_or_create_by!(source_key: 'application:skipped') do |event|
        event.kind = 'skipped'
        event.occurred_at = Time.current
      end
      return
    end

    message.message_id = delivery.email_message_id || "#{SecureRandom.uuid}@#{ENV.fetch('SMTP_DOMAIN')}"
    recipient = delivery.recipient
    recipient.with_lock do
      return if recipient.email.nil?
      delivery.update!(email_message_id: message.message_id, email_address: message.to.fetch(0), email_subject: message.subject)
    end
    if message.delivery_method.is_a?(Mail::SMTP)
      message.delivery_method(NotificationSmtpDelivery, message.delivery_method.settings)
    end

    mailer.deliver_now
    provider_message_id = if message.delivery_method.is_a?(NotificationSmtpDelivery) &&
      message.delivery_method.settings.fetch(:address).match?(/\Aemail-smtp\.[a-z0-9-]+\.amazonaws\.com\z/)
      message.delivery_method.response.string.match(/\A250 Ok ([a-zA-Z0-9-]+)\s*\z/)&.[](1)
    end
    recipient.with_lock do
      # A redaction committed while SMTP was in flight must not have its
      # erased provider identifiers restored by this worker's completion.
      return if recipient.email.nil?
      delivery.update!(delivered_at: Time.current, provider_message_id: provider_message_id)
      delivery.events.create!(kind: 'sent', source_key: "application:sent:#{message.message_id}", occurred_at: delivery.delivered_at)
    end
  rescue Net::SMTPFatalError, Net::SMTPServerBusy => error
    NotificationEmailEventService.record!(delivery: delivery, kind: error.is_a?(Net::SMTPFatalError) ? 'rejected' : 'delayed',
      source_key: "smtp:#{SecureRandom.uuid}", occurred_at: Time.current, detail: error.message.truncate(2000))
    raise
  end
end
