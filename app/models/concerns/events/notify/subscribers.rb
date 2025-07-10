module Events::Notify::Subscribers
  def trigger!
    super
    send_subscriber_emails!
  end

  def send_subscriber_emails!
    subscribed_recipients.active.no_spam_complaints.pluck(:id).each do |recipient_id|
      EventMailer.event(recipient_id, id).deliver_later
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
end
