module Events::VisitorEvent
  include Events::Notify::Users

  def mailer
    PollMailer
  end

  def poll
    @poll ||= Poll.find custom_fields['poll_id']
  end

  private

  def email_recipients
    Visitor.where(id: self.eventable_id)
  end

  def communities
    Array(eventable&.community)
  end

end
