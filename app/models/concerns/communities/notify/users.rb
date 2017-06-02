module Communities::Notify::Users
  def notify!(event)
    super
    event.email_users! if event.respond_to?(:email_users!)
  end
end
