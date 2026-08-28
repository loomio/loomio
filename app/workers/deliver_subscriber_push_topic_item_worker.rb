class DeliverSubscriberPushTopicItemWorker < ApplicationJob
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(push_subscription_id, topic_item_id)
    subscription = PushSubscription.active.find_by(id: push_subscription_id)
    topic_item = TopicItem.find_by(id: topic_item_id)
    return unless subscription && topic_item&.itemable

    user = subscription.user
    topic = topic_item.topic
    return unless topic.push_loud_members.exists?(user.id)
    return unless PushDeliveryPolicy.allowed?(user: user, subject: topic_item)

    I18n.with_locale(user.locale) do
      WebPushService.deliver!(
        subscription: subscription,
        payload: PushPayloadService.for_topic_item(topic_item: topic_item, recipient: user)
      )
    end
  end
end
