module Communities::NotifyViaEmail
  def notify!(event)
    super
    event.email_users!  if event.respond_to?(:email_users!)
  end
end
