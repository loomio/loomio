class Events::PollEdited < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(poll, actor)
    super(poll, user: actor)
  end

  private
  def notify_webhooks?
    !(eventable.discussion && eventable.discussion.visible_to != 'discussion')
  end
end
