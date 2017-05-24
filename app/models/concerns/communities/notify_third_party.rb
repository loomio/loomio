module Communities::NotifyThirdParty
  def notify!(event)
    identity&.notify!(event)
  end
end
