module Communities::NotifyThirdParty
  def notify!(event)
    super
    identity&.notify!(event)
  end

  def includes?(participant)
    participant.identities.any? { |i| i.is_member_of?(self) }
  end
end
