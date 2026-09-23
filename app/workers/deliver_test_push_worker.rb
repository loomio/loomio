class DeliverTestPushWorker < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(push_subscription_id)
    subscription = PushSubscription.active.includes(:user).find_by(id: push_subscription_id)
    return unless subscription

    I18n.with_locale(subscription.user.locale) do
      WebPushService.deliver!(
        subscription: subscription,
        payload: PushPayloadService.for_test
      )
    end
  end
end
