class Events::PollCreated < Event
  include Events::LiveUpdate
  include Events::Notify::Mentions
  include Events::Notify::Chatbots

  def self.publish!(poll, actor, recipient_user_ids: [])
    super poll,
          user: actor,
          discussion: poll.discussion,
          pinned: true,
          recipient_user_ids: recipient_user_ids
  end
end
