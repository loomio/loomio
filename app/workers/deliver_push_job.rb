class DeliverPushJob
  include Sidekiq::Worker

  def perform(subscription_id, event_id)
    PushService.send_notification(subscription_id, event_id)
  end
end
