class Events::PollEdited < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(poll, user_ids, audience, message)
    super(poll,
          discussion_id: (message && poll.discussion_id) || nil,
          user: poll.author,
          recipient_user_ids: user_ids,
          recipient_audience: audience,
          recipient_message: message)
  end
end
