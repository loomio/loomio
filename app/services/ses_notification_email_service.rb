require 'aws-sdk-sesv2'

# SMTP still sends the email. Message Insights supplies delivery evidence later,
# scoped to the exact provider message ID and snapshotted recipient. Do not import
# opens or clicks, or use another recipient's event to infer this one's status.
class SesNotificationEmailService
  KINDS = { 'DELIVERY' => 'delivered', 'DELIVERY_DELAY' => 'delayed', 'REJECT' => 'rejected',
           'RENDERING_FAILURE' => 'rejected', 'BOUNCE' => 'bounced', 'COMPLAINT' => 'complained' }.freeze
  TERMINAL_KINDS = %w[delivered rejected bounced complained].freeze

  def self.client
    Aws::SESV2::Client.new(region: ENV.fetch('SES_MESSAGE_INSIGHTS_REGION'),
      retry_limit: 0, http_open_timeout: 5, http_read_timeout: 5)
  end

  def self.sync!(delivery, client:)
    if delivery.delivered_at < 30.days.ago
      delivery.update!(email_sync_due_at: nil)
      return
    end

    message_id = delivery.provider_message_id
    response = client.get_message_insights(message_id: message_id)
    raise 'SES returned a different message ID' unless response.message_id == message_id
    insights = response.insights.find { |item| item.destination.casecmp?(delivery.email_address) }
    raise 'SES returned no matching recipient' unless insights

    insights.events.each do |event|
      kind = KINDS[event.type]
      next unless kind
      raise 'SES returned an event without a timestamp' unless event.timestamp

      detail = if event.details&.bounce
        event.details.bounce.diagnostic_code
      elsif event.details&.complaint
        event.details.complaint.complaint_feedback_type
      end
      NotificationEmailEventService.record!(delivery: delivery, kind: kind,
        source_key: "ses:#{delivery.provider_message_id}:#{event.type}:#{event.timestamp.iso8601(6)}",
        occurred_at: event.timestamp, detail: detail&.truncate(2000))
    end
    # Stop polling a terminal result; later complaints are still accepted through
    # the existing email feedback path. Pending sends use a bounded backoff.
    delivery.with_lock do
      return if delivery.email_address.nil? || delivery.provider_message_id != message_id
      due_at = unless delivery.events.where(kind: TERMINAL_KINDS).exists?
        delivery.delivered_at > 1.hour.ago ? 5.minutes.from_now : 1.hour.from_now
      end
      delivery.update!(email_sync_due_at: due_at)
    end
  rescue Aws::SESV2::Errors::NotFoundException
    # VDM is eventually consistent. Absence must not be presented as a bounce.
    delivery.with_lock do
      delivery.update!(email_sync_due_at: 10.minutes.from_now) if delivery.provider_message_id == message_id
    end
  end
end
