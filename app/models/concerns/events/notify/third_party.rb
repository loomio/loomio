module Events::Notify::ThirdParty
  def trigger!
    super
    NotifyWebhooksWorker.perform_async(self.id)
  end
end
