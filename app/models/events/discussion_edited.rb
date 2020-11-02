class Events::DiscussionEdited < Event
  include Events::LiveUpdate
  include Events::Notify::InApp
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty

  def self.publish!(discussion:, user_ids: [], message: nil)
    super(discussion,
          discussion_id: (message && discussion.id) || nil,
          user: discussion.author,
          recipient_user_ids: user_ids,
          recipient_message: message)
  end

  def discussion
    eventable
  end
end
