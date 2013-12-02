class NotificationItems::MotionClosedByUser < NotificationItems::MotionClosed
  def action_text
    I18n.t('notifications.motion_closed.by_user')
  end
end
