class Events::PollClosingSoon < Event
  include Events::Notify::InApp
  include Events::Notify::Author
  include Events::Notify::ByEmail
  include Events::Notify::ThirdParty

  def self.publish!(poll)
    super poll,
          user: poll.author,
          created_at: Time.now
  end

  private

  def email_recipients
    notification_recipients
  end
  
  def notification_recipients
    users = Queries::UsersByVolumeQuery.normal_or_loud(poll)
    if poll.voters_review_responses
      users
    else
      users.where.not(id: poll.participants)
    end
  end

  def notification_translation_values
    super.merge(poll_type: I18n.t(:"poll_types.#{eventable.poll_type}"))
  end
end
