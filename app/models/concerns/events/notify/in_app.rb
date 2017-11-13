module Events::Notify::InApp
  include PrettyUrlHelper

  def trigger!
    super
    self.notify_users!
  end

  # send event notifications
  def notify_users!
    notifications.import(notification_recipients.active.without(user).map do |recipient|
      notifications.build({user: recipient}.merge(notification_params))
    end)
  end
  handle_asynchronously :notify_users!

  private

  # which users should receive an in-app notification about this event?
  # (NB: This must return an ActiveRecord::Relation)
  def notification_recipients
    User.none
  end

  def notification_params
    return {} unless eventable
    actor = user || (eventable.author if eventable.respond_to?(:author))
    @notification_params ||= {
      actor:       actor,                       # defines the avatar which appears next to the notification
      url:         polymorphic_url(eventable),  # defines the link that clicking on the notification takes you to
      translation_values: {                     # defines values to be passed to the translation for the notification
        name:      actor&.name,
        title:     polymorphic_title(eventable),
        poll_type: eventable_poll_type
      }
    }
  end

  def eventable_poll_type
    return unless eventable.respond_to?(:poll)
    I18n.t(:"poll_types.#{eventable.poll.poll_type}").downcase
  end
end
