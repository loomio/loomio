module Events::Notify::ByWebPush
  def trigger!
    super
    push_users!
  end

  # send web push notifications to push_recipients
  def push_users!
    push_recipients.active.uniq.each do |recipient|
      recipient.web_push_subscriptions.find_each do |subscription|
        WebPushService.send_notification(subscription, self)
      end
    end
  end

  private

  def push_recipients
    Queries::UsersByVolumeQuery.push_notifications(eventable).where(id: all_recipient_user_ids).where.not(id: user.id || 0)
  end
end
