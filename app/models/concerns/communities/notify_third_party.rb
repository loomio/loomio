module Communities::NotifyThirdParty
  def notify!(event)
    identity.notify!(event, identifier)
  end
end
