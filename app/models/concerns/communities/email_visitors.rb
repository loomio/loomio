module Communities::EmailVisitors
  EMAIL_EVENTS = %w(outcome_created poll_created)

  def notify!(event)
    members.where('email IS NOT NULL').each do |recipient|
      event.mailer.send(event.kind, recipient, event).deliver_now
    end if EMAIL_EVENTS.include?(event.kind)
  end
end
