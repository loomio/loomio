class Events::PollExpired < Event
  include Events::Notify::Author
  include Events::Notify::ThirdParty
  include Events::Notify::InApp

  def self.publish!(poll)
    super poll,
          discussion: poll.discussion,
          created_at: poll.closed_at
  end

  private

  # email the author and create an in-app notification
  def email_author!
    super
    notification_for(author).save
  end
end
