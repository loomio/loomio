module Events::Notify::ByPush
  def trigger!
    super
    push_users!
  end

  def push_users!
    subscription_ids = PushSubscription
      .where(user_id: push_recipient_ids)
      .pluck(:id)
    subscription_ids.each do |subscription_id|
      DeliverPushJob.perform_async(subscription_id, id)
    end
  end

  private

  def push_recipient_ids
    Queries::UsersByVolumeQuery.push_notifications(eventable)
      .where(id: all_recipient_user_ids)
      .where.not(id: user.id || 0)
      .distinct.pluck(:id)
  end
end
