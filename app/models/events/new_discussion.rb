class Events::NewDiscussion < Event
  include Events::LiveUpdate
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(discussion, user_ids = [], audience = nil)
    super(discussion,
          user: discussion.author,
          recipient_user_ids: user_ids,
          recipient_audience: audience)
  end

  def discussion
    eventable
  end
end
