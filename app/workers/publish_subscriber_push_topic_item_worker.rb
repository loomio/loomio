class PublishSubscriberPushTopicItemWorker < ApplicationJob
  def perform(topic_item_id)
    topic_item = TopicItem.find_by(id: topic_item_id)
    return unless topic_item&.itemable

    topic = topic_item.topic || topic_item.itemable.topic
    recipient_ids = topic.push_loud_members
                         .where.not(id: topic_item.actor_id)
                         .where.not(id: topic_item.itemable.mentioned_users)
                         .where.not(id: topic_item.itemable.mentioned_group_users)
                         .where.not(id: topic_item.notification_recipient_user_ids)
                         .pluck(:id)

    PushSubscription.active.where(user_id: recipient_ids).pluck(:id).each do |subscription_id|
      DeliverSubscriberPushTopicItemWorker.perform_later(subscription_id, topic_item.id)
    end
  end
end
