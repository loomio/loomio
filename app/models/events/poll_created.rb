class Events::PollCreated < Event
  include Events::LiveUpdate
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(poll, actor)
    super poll,
          user: actor,
          discussion: poll.discussion,
          pinned: true
  end

  private
  def notify_webhooks?
    !(eventable.discussion && eventable.discussion.visible_to != 'discussion')
  end
end
