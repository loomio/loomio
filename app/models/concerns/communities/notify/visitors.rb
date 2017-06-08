module Communities::Notify::Visitors
  def notify!(event)
    super
    event.email_visitors! if event.respond_to?(:email_visitors!)
  end
end
