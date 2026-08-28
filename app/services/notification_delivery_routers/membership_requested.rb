module NotificationDeliveryRouters
  class MembershipRequested < NotificationDeliveryRouter
    def self.translation_values(membership_request, actor, locale: actor.locale)
      I18n.with_locale(locale) do
        {
          name: membership_request.requestor&.name || membership_request.name,
          title: membership_request.group.full_name
        }
      end
    end

    subject_model_class MembershipRequest

    def recipients_by_channel
      membership_request = subject_model
      recipients(membership_request.admins.active, volume: membership_request.group)
    end
  end
end
