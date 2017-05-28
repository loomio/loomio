module Communities::NotifyThirdParty
  def notify!(event)
    super
    identity&.notify!(event)
  end
end
