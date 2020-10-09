class Events::NewDiscussion < Event
  include Events::LiveUpdate
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(discussion)
    super discussion, user: discussion.author
  end

  def discussion
    eventable
  end
end
