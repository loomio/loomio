module Events::VisitorEvent
  include Events::Notify::Visitors

  def mailer
    PollMailer
  end

  def poll
    @poll ||= Poll.find custom_fields['poll_id']
  end

  private

  def email_visitors
    Visitor.where(id: self.eventable_id)
  end

  def communities
    Array(eventable&.community)
  end

end
