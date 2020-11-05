class Events::OutcomeReviewDue < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::ThirdParty

  def self.publish!(outcome)
    super outcome,
          user: outcome.author
  end

  private
  def email_recipients
    Queries::UsersByVolumeQuery.email_notifications(poll)
                               .where('users.id': raw_recipients.pluck(:id))
  end

  def notification_recipients
    Queries::UsersByVolumeQuery.app_notifications(poll)
                               .where('users.id': raw_recipients.pluck(:id))
  end

  def raw_recipients
    User.where(id: eventable.author_id)
  end
end
