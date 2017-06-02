module Communities::Notify::InApp
  def notify!(event)
    super
    event.notify_users! if event.respond_to?(:notify_users!)
  end
end
