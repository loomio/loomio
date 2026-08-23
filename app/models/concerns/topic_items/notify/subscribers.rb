module TopicItems::Notify::Subscribers
  def trigger!
    super
    send_subscriber_emails!
  end

  def send_subscriber_emails!
    subscribed_recipients.active.no_spam_complaints.pluck(:id).each do |recipient_id|
      DeliveryMailer.topic_item(recipient_id, id).deliver_later
    end
  end

  def subscribed_recipients
    (topic || itemable.topic).volume_loud_members
                               .where.not(id: itemable.author)
                               .where.not(id: itemable.mentioned_users)
                               .where.not(id: itemable.mentioned_group_users)
                               .where.not(id: all_recipient_user_ids)
                               .distinct
  end
end
