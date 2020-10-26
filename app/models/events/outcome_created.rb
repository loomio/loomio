class Events::OutcomeCreated < Event
  include Events::Notify::ThirdParty
  include Events::Notify::Mentions
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::LiveUpdate

  attr_accessor :recipients

  private

  def notification_recipients
    @recipients
  end

  def email_recipients
    Queries::UsersByVolumeQuery.normal_or_loud(eventable)
      .where('users.id': @recipients.map(&:id))
      .where.not(id: eventable.newly_mentioned_users)
  end
end
