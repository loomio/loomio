class NotificationItems::MembershipRequested < NotificationItem
  attr_accessor :notification

  def initialize(notification)
    @notification = notification
  end

  def actor
    requestor = notification.eventable.requestor
    if requestor
      requestor
    else
      visitor = LoggedOutUser.new(name: notification.eventable.name,
                                 email: notification.eventable.email)
      visitor.set_avatar_initials
      visitor
    end
  end

  def action_text
    I18n.t('notifications.membership_requested')
  end

  def title
    notification.eventable.group_name
  end

  def group_full_name
    notification.eventable.group_name
  end

  def link
    Routing.group_membership_requests_path(notification.eventable.group)
  end
end
