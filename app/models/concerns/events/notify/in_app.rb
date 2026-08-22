module Events::Notify::InApp
  def trigger!
    super
    notify_users!
  end

  # send event notifications
  def notify_users!
    @notification_user_ids_attempted = built_notifications.map(&:user_id)
    notifications_created = NotificationService.create_for_event!(
      event: self,
      notifications: built_notifications
    )
    @notification_user_ids_created = notifications_created.map(&:user_id)
    notifications_created.each do |notification|
      MessageChannelService.publish_models([ notification ], user_id: notification.user_id)
    end
    notifications_created
  end

  private

  def built_notifications
    @built ||= notification_recipients.active.map { |recipient| notification_for(recipient) }
  end

  def notification_for(recipient)
    I18n.with_locale(recipient.locale) do
      notifications.build(
        user: recipient,
        actor: notification_actor,
        translation_values: notification_translation_values
      )
    end
  end

  # defines the avatar which appears next to the notification
  def notification_actor
    user.presence
  end

  # defines the values that are passed to the translation for notification text
  # by default we infer the values needed from the eventable class,
  # but this method can be overridden with any translation values for a particular event
  def notification_translation_values
    {
      name: notification_translation_name,
      title: TranslationService.plain_text(eventable.title_model, :title, user),
      poll_type: (I18n.t(:"poll_types.#{notification_poll_type}") if notification_poll_type)
    }.compact
  end

  def notification_translation_name
    notification_actor&.name
  end

  def notification_poll_type
    eventable.poll_type if eventable.respond_to?(:poll_type)
  end

  # Email-only recipients have no in-app identity to gate yet. For recipients
  # covered by this notification attempt, permit email only when its row was
  # newly inserted.
  def did_create_in_app_notification_for?(user_id)
    return true unless defined?(@notification_user_ids_attempted)
    return true unless @notification_user_ids_attempted.include?(user_id)

    @notification_user_ids_created.include?(user_id)
  end
end
