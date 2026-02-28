class Events::OutcomeReviewDue < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Chatbots

  def self.publish!(outcome)
    super outcome,
          user: outcome.author
  end

  private
  def email_recipients
    poll.topic.email_notification_members
              .where('users.id': raw_recipients.pluck(:id))
  end

  def notification_recipients
    poll.topic.app_notification_members
              .where('users.id': raw_recipients.pluck(:id))
  end

  def raw_recipients
    User.where(id: eventable.author_id)
  end
end
