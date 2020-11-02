class Events::DiscussionAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(discussion:, actor:, recipient_user_ids:, recipient_audience: nil)
    super(discussion,
          user: actor,
          recipient_user_ids: recipient_user_ids,
          recipient_audience: recipient_audience)
  end
end
