class PublishSubscriberEmailsTopicItemWorker < ApplicationJob
  def perform(topic_item_id)
    topic_item = TopicItem.find_by(id: topic_item_id)
    return unless topic_item&.itemable

    topic = topic_item.topic || topic_item.itemable.topic
    topic.volume_loud_members
         .where.not(id: topic_item.itemable.author)
         .where.not(id: topic_item.itemable.mentioned_users)
         .where.not(id: topic_item.itemable.mentioned_group_users)
         .active
         .no_spam_complaints
         .distinct
         .pluck(:id)
         .each do |recipient_id|
      NotificationMailer.topic_item(recipient_id, topic_item.id).deliver_later
    end
  end
end
