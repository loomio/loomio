module Communities::NotifyLoomioGroup
  def notify!(event)
    event.email_users!  if event.respond_to?(:email_users!)
    event.notify_users! if event.respond_to?(:notify_users!)
    event.notify_slack! if event.respond_to?(:notify_slack_channel!)
  end
end
