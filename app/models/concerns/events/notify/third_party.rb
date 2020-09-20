module Events::Notify::ThirdParty
  def trigger!
    super
    NotifyWebhooksWorker.perform_async(self.id) if notify_webhooks?
  end

  def notify_webhooks?
    false
  end
end
