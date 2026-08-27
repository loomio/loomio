class WebPushService
  def self.configured?
    %w[VAPID_PUBLIC_KEY VAPID_PRIVATE_KEY VAPID_SUBJECT].all? { |key| ENV[key].present? }
  end

  def self.deliver!(subscription:, payload:)
    raise "Web Push is not configured" unless configured?

    WebPush.payload_send(
      message: payload.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: {
        subject: ENV.fetch('VAPID_SUBJECT'),
        public_key: ENV.fetch('VAPID_PUBLIC_KEY'),
        private_key: ENV.fetch('VAPID_PRIVATE_KEY')
      }
    )
    subscription.update!(failure_count: 0, last_seen_at: Time.current)
  rescue WebPush::InvalidSubscription, WebPush::ExpiredSubscription
    subscription.revoke!
    nil
  rescue StandardError
    subscription.increment!(:failure_count)
    raise
  end
end
