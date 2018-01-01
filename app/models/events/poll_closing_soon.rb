class Events::PollClosingSoon < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Author
  include Events::Notify::ThirdParty

  def self.publish!(poll)
    super poll,
          user: poll.author,
          parent: poll.created_event
  end

  private

  def email_recipients
    notification_recipients.where(email_announcements: true)
  end

  def notification_recipients
    recipients = poll.users_from_announcements
    recipients = recipients.without(poll.participants) unless poll.voters_review_responses
    recipients
  end
end
