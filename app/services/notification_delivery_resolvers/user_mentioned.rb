module NotificationDeliveryResolvers
  class UserMentioned < NotificationDeliveryResolver
    private

    def recipients_by_channel
      recipients = explicit_users.active.verified
      {
        "in_app" => recipients.to_a,
        "email" => email_users_for(recipients.where(email_when_mentioned: true)).to_a
      }
    end
  end
end
