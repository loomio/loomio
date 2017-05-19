module Communities::NotifyThirdParty
  PUBLISH_EVENTS = %w(group_published outcome_published poll_published).freeze

  def notify!(event)
    identity.notify!(event) if identity && PUBLISH_EVENTS.include?(event.kind)
  end
end
