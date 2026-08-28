module NotificationDeliveryResolvers
  class UnknownSender < NotificationDeliveryResolver
    def self.translation_values(received_email, _actor, locale: I18n.default_locale)
      I18n.with_locale(locale) do
        { title: received_email.group.full_name }
      end
    end

    private

    def recipients_by_channel
      received_email = notification.subject_model
      unless received_email.is_a?(ReceivedEmail)
        raise ArgumentError, "unknown_sender subject must be a ReceivedEmail"
      end

      user_recipients_by_channel(
        received_email.group.admins.active,
        email: User.none,
        push: received_email.group.push_enabled_members
      )
    end
  end
end
