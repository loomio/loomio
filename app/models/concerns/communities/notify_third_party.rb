module Communities::NotifyThirdParty
  PUBLISH_EVENTS = %w(outcome_published poll_published).freeze

  def notify!(event)
    return unless PUBLISH_EVENTS.include?(event.kind)
    identity.notify!(event)
  end

  def includes?(participant)
    participant.identities.any? { |i| i.is_member_of?(self) }
  end
end
