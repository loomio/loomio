module SubscriptionHelper

  def chargify_subscription_url(subscription)
    ChargifyService.new(subscription.chargify_subscription_id).subscription_url
  end
end
