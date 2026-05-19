class Events::PollClosedByUser < Event
  include Events::LiveUpdate
  include Events::Notify::Chatbots
  
  def self.publish!(poll, actor)
    super poll,
          user: actor,
          topic: poll.topic,
          created_at: poll.closed_at
  end
end
