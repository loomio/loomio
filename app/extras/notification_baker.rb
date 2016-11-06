class NotificationBaker
  # In order for old notifications to have the correct fields, they must be 'baked'
  # ie, have their new url & translation values stored on them. This class handles that,
  # and is called once per user when they visit the app.

  # This code isn't very pretty, but it gets the job done and once all users have rebaked their
  # notifications, we can get rid of it.
  def self.bake!(notifications)
    notifications.includes(:event).reject { |n| n.url && n.translation_values }.each do |notification|
      return unless Event::NOTIFICATION_KINDS.include?(notification.kind)
      @event = Events.const_get(notification.kind.camelize).new(notification.event.as_json)
      notification.update(
        url:                @event.send(:notification_url),
        actor:              @event.send(:notification_actor),
        translation_values: @event.send(:notification_translation_values)
      )
    end
  end
end
