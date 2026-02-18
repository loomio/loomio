class Events::PollCreated < Event
  include Events::LiveUpdate
  include Events::Notify::Mentions
  include Events::Notify::Chatbots
  include Events::Notify::ByWebPush
  include Events::Notify::Subscribers

  def self.publish!(poll, actor)
    super poll,
          user: actor,
          discussion: poll.discussion,
          pinned: true
  end
end
