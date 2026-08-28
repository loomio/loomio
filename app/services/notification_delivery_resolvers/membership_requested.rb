module NotificationDeliveryResolvers
  class MembershipRequested < NotificationDeliveryResolver
    def self.translation_values(membership_request, actor, locale: actor.locale)
      I18n.with_locale(locale) do
        {
          name: membership_request.requestor&.name || membership_request.name,
          title: membership_request.group.full_name
        }
      end
    end

    private

    def recipients_by_channel
      membership_request = notification.subject_model
      unless membership_request.is_a?(MembershipRequest)
        raise ArgumentError, "membership_requested subject must be a MembershipRequest"
      end

      user_recipients_by_channel(
        membership_request.admins.active,
        email: membership_request.group.email_enabled_members,
        push: membership_request.group.push_enabled_members
      )
    end
  end
end
