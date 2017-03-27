module Communities::NotifyThirdParty
  def notify!(event)
    identity.notify!(event.kind, event.eventable, identifier)
  end
end
