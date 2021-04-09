class Events::DiscussionAnnounced < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(discussion:, actor:, recipient_user_ids:, recipient_audience: nil, recipient_message: nil)
    super(discussion,
          user: actor,
          recipient_user_ids: Array(recipient_user_ids).uniq.compact,
          recipient_audience: recipient_audience.presence,
          recipient_message: recipient_message.presence)
  end
end
