module NotificationDeliveryRouters
  class UnknownSender < NotificationDeliveryRouter
    def self.translation_values(received_email, _actor, locale: I18n.default_locale)
      I18n.with_locale(locale) do
        { title: received_email.group.full_name }
      end
    end

    subject_model_class ReceivedEmail

    def recipients_by_channel
      received_email = subject_model
      recipients(received_email.group.admins.active)
    end
  end
end
