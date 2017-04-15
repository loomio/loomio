module Communities::NotifyThirdParty
  PUBLISH_EVENTS = %w(outcome_published poll_published).freeze

  def notify!(event)
    return unless PUBLISH_EVENTS.include?(event.kind)
    identity.notify!(event)
  end
end
