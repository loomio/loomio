module Events::NotifyUser
  include PrettyUrlHelper

  def trigger!
    super
    notify_users!
  end

  # send event notifications
  def notify_users!
    notifications.import(notification_recipients.without(user).map do |recipient|
      notifications.build(user:               recipient,
                          actor:              notification_actor,
                          url:                notification_url,
                          translation_values: notification_translation_values)
    end)
  end
  handle_asynchronously :notify_users!

  private

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
    { name: notification_translation_name, title: notification_translation_title }
  end

  def notification_translation_name
    notification_actor&.name
  end

  def notification_translation_title
    case eventable
    when PaperTrail::Version              then eventable.item.title
    when Comment, CommentVote, Discussion then eventable.discussion.title
    when Group, Membership                then eventable.group.full_name
    when Poll, Outcome                    then eventable.poll.title
    when Motion                           then eventable.name
    end
  end
end
