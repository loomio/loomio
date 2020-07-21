class Events::DiscussionEdited < Event
  include Events::LiveUpdate
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(discussion, editor)
    super(discussion, user: editor)
  end

  def discussion
    eventable
  end
end
