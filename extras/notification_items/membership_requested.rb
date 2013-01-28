class NotificationItems::MembershipRequested < NotificationItem
  attr_accessor :notification

  delegate :url_helpers, to: 'Rails.application.routes'

  def initialize(notification)
    @notification = notification
  end

  def action_text
    I18n.t('notifications.membership_requested')
  end

  def title
    @notification.eventable.group_full_name
  end

  def link
    url_helpers.group_path(@notification.eventable.group)
  end
end
