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

  # 'super' here are the people who were notified when the poll was first created
  def email_recipients
    users_who_care(super)
  end

  def notification_recipients
    users_who_care(super)
  end

  private

  def users_who_care(relation)
    if eventable.voters_review_responses
      # remind notified users, plus ask participants to review
      users_in_any(relation, eventable.participants)
    else
      # remind notified users, but don't notify participants
      relation.without(eventable.participants)
    end.without(eventable.unsubscribers)
  end
end
