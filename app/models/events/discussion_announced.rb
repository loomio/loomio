class Events::DiscussionAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(discussion:, actor:, user_ids:)
    super(discussion, user: actor, recipient_user_ids: user_ids)
  end
end
