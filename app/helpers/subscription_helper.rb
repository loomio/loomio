module SubscriptionHelper

  def chargify_subscription_link(subscription)
    return unless Rails.application.secrets.chargify_app_name && subscription.chargify_subscription_id
    link_to subscription.chargify_subscription_id, "http://#{Rails.application.secrets.chargify_app_name}.chargify.com/subscriptions/#{subscription.chargify_subscription_id}", target: '_blank'
  end
end
