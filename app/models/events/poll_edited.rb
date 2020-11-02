class Events::PollEdited < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(poll:, recipient_user_ids: [], recipient_message: nil, recipient_audience: nil)
    super(poll,
          discussion_id: (recipient_message && poll.discussion_id) || nil,
          user: poll.author,
          recipient_user_ids: recipient_user_ids,
          recipient_audience: recipient_audience,
          recipient_message: recipient_message)
  end
end
