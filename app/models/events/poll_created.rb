class Events::PollCreated < Event
  include Events::LiveUpdate
  include Events::PollEvent
  include Events::Notify::ThirdParty

  def self.publish!(poll, actor)
    super poll,
          user: actor,
          discussion: poll.discussion
  end
end
