class SyncNotificationEmailsWorker < ApplicationJob
  limits_concurrency to: 1, key: 'ses-message-insights', duration: 10.minutes

  # SES permits one GetMessageInsights request per second. One bounded batch
  # avoids a job per recipient and never puts AWS calls on the history request.
  def perform
    return unless ENV['SES_MESSAGE_INSIGHTS_REGION'].present?

    client = SesNotificationEmailService.client
    NotificationDelivery.where('email_sync_due_at <= ?', Time.current)
      .order(:email_sync_due_at, :id).limit(20).each_with_index do |delivery, index|
      sleep 1 if index.positive?
      SesNotificationEmailService.sync!(delivery, client: client)
    end
  end
end
