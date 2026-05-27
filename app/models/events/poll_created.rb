class Events::PollCreated < Event
  include Events::LiveUpdate
  include Events::Notify::Mentions
  include Events::Notify::Chatbots
  include Events::Notify::Subscribers

  def self.publish!(poll, actor)
    super poll,
          user: actor,
          topic: poll.topic,
          pinned: true
  end
end
