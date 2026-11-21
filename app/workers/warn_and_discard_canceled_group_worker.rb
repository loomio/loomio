class WarnAndDiscardCanceledGroupWorker < ApplicationJob
  queue_as :low

  def self.enqueue_for(group_id, subscription, source, evidence = nil)
    effective_at = [subscription.expires_at, subscription.canceled_at].compact.max
    job = effective_at&.future? ? set(wait_until: effective_at) : self
    job.perform_later(group_id, subscription.id, source, evidence)
  end

  def perform(group_id, subscription_id, source, evidence)
    if source == "chargify"
      subscription = Subscription.find_by(id: subscription_id, state: "canceled", chargify_subscription_id: evidence)
      return unless subscription && defined?(SubscriptionService)

      billing = SubscriptionService.chargify_get(subscription.chargify_subscription_id)
      return unless billing["state"] == "canceled"
      return if billing["expires_at"].present? && Time.iso8601(billing["expires_at"]).future?
    end

    GroupService.warn_and_discard_canceled_subscription(
      group_id: group_id, subscription_id: subscription_id, source: source, evidence: evidence
    )
  end
end
