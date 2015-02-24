class NotificationItems::MembershipRequestApproved < NotificationItem
  attr_accessor :notification


  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.membership_request_approved')
  end

  def title
    @notification.eventable.group_full_name
  end

  def link
    Routing.group_path(@notification.eventable.group)
  end

  def actor
    @notification.event.user or @notification.user
  end
end
