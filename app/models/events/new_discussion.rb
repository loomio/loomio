class Events::NewDiscussion < Event
  include Events::LiveUpdate
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(discussion:, recipient_user_ids: [], recipient_audience: nil, recipient_message: nil)
    super(discussion,
          user: discussion.author,
          recipient_user_ids: Array(recipient_user_ids).uniq.compact,
          recipient_audience: recipient_audience.presence,
          recipient_message: recipient_message.presence)
  end

  def discussion
    eventable
  end
end
