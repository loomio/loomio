module NotificationDeliveryRouters
  class UnknownSender < NotificationDeliveryRouter
    def translation_values
      { title: subject_model.group.full_name }
    end

    def recipients_by_channel
      received_email = subject_model
      recipients(received_email.group.admins.active)
    end
  end
end
