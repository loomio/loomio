module Events::Notify::Subscribers
  def trigger!
    super
    send_subscriber_emails!
    send_subscriber_push_notifications!
  end

  def send_subscriber_emails!
    subscribed_recipients.active.no_spam_complaints.pluck(:id).each do |recipient_id|
      EventMailer.event(recipient_id, id).deliver_later
    end
  end

  def send_subscriber_push_notifications!
    subscription_ids = PushSubscription
      .where(user_id: push_subscribed_recipient_ids)
      .pluck(:id)
    subscription_ids.each do |sid|
      DeliverPushJob.perform_async(sid, id)
    end
  end

  def subscribed_eventable
    eventable.discussion || eventable.poll
  end

  def subscribed_recipients
    Queries::UsersByVolumeQuery.loud(subscribed_eventable)
                               .where.not(id: eventable.author)
                               .where.not(id: eventable.mentioned_users)
                               .where.not(id: eventable.mentioned_group_users)
                               .where.not(id: all_recipient_user_ids)
                               .distinct
  end

  def push_subscribed_recipient_ids
    Queries::UsersByVolumeQuery.push_loud(subscribed_eventable)
      .where.not(id: eventable.author)
      .where.not(id: eventable.mentioned_users)
      .where.not(id: eventable.mentioned_group_users)
      .where.not(id: all_recipient_user_ids)
      .distinct.pluck(:id)
  end
end
