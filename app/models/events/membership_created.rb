class Events::MembershipCreated < Event
  include Events::Notify::InApp
  include Events::Notify::ByEmail

  def self.publish!(
    group:,
    actor:,
    recipient_user_ids:,
    recipient_message: nil)
    super group,
          user: actor,
          recipient_message: recipient_message,
          recipient_user_ids: recipient_user_ids
  end
end
