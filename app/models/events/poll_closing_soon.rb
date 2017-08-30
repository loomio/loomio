class Events::PollClosingSoon < Event
  include Events::Notify::Author
  include Events::Notify::Users
  include Events::Notify::FromAuthor
  include Events::Notify::ThirdParty

  def self.publish!(poll)
    poll.notified = poll.notified_when_created
    super poll,
          user: poll.author,
          created_at: Time.now
  end

  private

  def email_recipients
    if eventable.voters_review_responses
      super.merge(eventable.participants)
    else
      super
    end
  end

end
