module Communities::Notify::ThirdParty
  def notify!(event)
    super
    identity&.notify!(event)
  end
end
