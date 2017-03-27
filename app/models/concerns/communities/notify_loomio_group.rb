module Communities::NotifyLoomioGroup
  def notify!(event)
    event.email_users!  if event.respond_to?(:email_users!)
    event.notify_users! if event.respond_to?(:notify_users!)
  end
end
