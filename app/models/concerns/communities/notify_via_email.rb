module Communities::NotifyViaEmail
  EMAIL_EVENTS = %w(outcome_created poll_created visitor_created visitor_reminded).freeze

  def notify!(event)
    return unless EMAIL_EVENTS.include?(event.kind)
    visitors.can_receive_email.each { |recipient| event.mailer.send(event.kind, recipient, event).deliver_now }
  end
end
