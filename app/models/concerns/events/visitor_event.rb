module Events::VisitorEvent

  def mailer
    PollMailer
  end

  def poll
    @poll ||= Poll.find custom_fields['poll_id']
  end

  private

  def communities
    Array(eventable&.community)
  end

end
