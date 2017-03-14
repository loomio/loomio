class Events::PollClosingSoon < Event
  include Events::PollEvent

  def self.publish!(poll)
    create(kind: "poll_closing_soon",
           user: poll.author,
           announcement: !!poll.events.find_by(kind: :poll_created)&.announcement,
           eventable: poll).tap { |e| EventBus.broadcast('poll_closing_soon_event', e) }
  end

  def email_users!
    super
    mailer.poll_closing_soon_author(user, self).deliver_now
  end

  private

  def announcement_notification_recipients
    return User.none unless poll.group
    recipients = poll.group.members
    recipients = recipients.without(poll.participants) unless poll.voters_review_responses
    recipients
  end

  def announcement_email_recipients
    return User.none unless poll.group
    recipients = Queries::UsersByVolumeQuery.normal_or_loud(poll.discussion)
    recipients = recipients.without(poll.participants) unless poll.voters_review_responses
    recipients
  end

  # don't notify mentioned users for poll closing soon
  def specified_notification_recipients
    User.none
  end
  alias :specified_email_recipients :specified_notification_recipients

end
