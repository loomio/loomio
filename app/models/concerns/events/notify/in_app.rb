module Events::Notify::InApp
  include PrettyUrlHelper

  def trigger!
    super
    self.notify_users!
  end

  # send event notifications
  def notify_users!
    notifications.import(built_notifications)
    built_notifications.each { |n| MessageChannelService.publish_model(n, to: n.message_channel) }
  end

  private

  def built_notifications
    @built ||= notification_recipients.active.where.not(id: user).map { |recipient| notification_for(recipient) }
  end

  def notification_for(recipient)
    I18n.with_locale(recipient.locale) do
      notifications.build(
        user:               recipient,
        actor:              notification_actor,
        url:                notification_url,
        translation_values: notification_translation_values
      )
    end
  end

  # which users should receive an in-app notification about this event?
  # (NB: This must return an ActiveRecord::Relation)
  def notification_recipients
    User.none
  end

  # defines the avatar which appears next to the notification
  def notification_actor
    @notification_actor ||= user || eventable&.author
  end

  # defines the link that clicking on the notification takes you to
  def notification_url
    @notification_url ||= polymorphic_url(eventable)
  end

  # defines the values that are passed to the translation for notification text
  # by default we infer the values needed from the eventable class,
  # but this method can be overridden with any translation values for a particular event
  def notification_translation_values
    {
      name:      notification_translation_name,
      title:     notification_translation_title,
      poll_type: (I18n.t(:"poll_types.#{notification_poll_type}") if notification_poll_type)
    }.compact
  end

  def notification_translation_name
    notification_actor&.name
  end

  def notification_translation_title
    polymorphic_title(eventable)
  end

  def notification_poll_type
    case eventable
    when Poll, Outcome, Stance then eventable.poll.poll_type
    end
  end
end
