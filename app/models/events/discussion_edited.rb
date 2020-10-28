class Events::DiscussionEdited < Event
  include Events::LiveUpdate
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(discussion, user_ids, audience)
    super(discussion,
          user: discussion.author,
          recipient_user_ids: user_ids,
          recipient_audience: audience)
  end

  def discussion
    eventable
  end
end
