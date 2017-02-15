module Communities::Loomio
  def notify!(event)
    event.join_discussion! if event.respond_to?(:join_discussion!)
    event.notify_clients!  if event.respond_to?(:notify_clients!) # we actually want this to always happen.
    event.notify_users!    if event.respond_to?(:notify_users!)
    event.email_users!     if event.respond_to?(:email_users!)
  end
end
