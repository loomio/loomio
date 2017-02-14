module Events::NotifyUser
  include PrettyUrlHelper

  def trigger!
    super
    notify_users!
  end

  # send event notifications
  def notify_users!(recipients = notification_recipients)
    notifications.import(recipients.map do |recipient|
      notifications.build(user:               recipient,
                          actor:              notification_actor,
                          url:                notification_url,
                          translation_values: notification_translation_values)
    end)
  end
  handle_asynchronously :notify_users!

  private

  # which users should receive an in-app notification about this event?
  def notification_recipients
    User.none
  end

  # defines the avatar which appears next to the notification
  def notification_actor
    @notification_actor ||= user || eventable.author
  end

  # defines the link that clicking on the notification takes you to
  def notification_url
    @notification_url ||= polymorphic_url(eventable)
  end

  # defines the values that are passed to the translation for notification text
  # by default we infer the values needed from the eventable class,
  # but these can be overridden in the event subclasses if need be
  def notification_translation_values
    { name: notification_actor&.name }.tap do |hash|
      case eventable
      when PaperTrail::Version       then hash[:title] = eventable.item.title
      when Comment, CommentVote      then hash[:title] = eventable.discussion.title
      when Group, Membership         then hash[:title] = eventable.group.full_name
      when Poll, Discussion, Outcome then hash[:title] = eventable.poll.title
      when Motion                    then hash[:title] = eventable.name
      end
    end
  end
end
