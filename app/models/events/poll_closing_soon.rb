class Events::PollClosingSoon < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Author
  include Events::Notify::ThirdParty

  def self.publish!(poll)
    super poll,
          user: poll.author,
          created_at: Time.now
  end

  private

  def email_recipients
    notification_recipients.where(id: Queries::UsersByVolumeQuery.normal_or_loud(poll).pluck(:id))
  end

  def notification_recipients
    recipients = poll.users_notified
    recipients = recipients.where.not(id: poll.participants) unless poll.voters_review_responses
    recipients
  end

  def notification_translation_values
    super.merge(poll_type: I18n.t(:"poll_types.#{eventable.poll_type}"))
  end
end
