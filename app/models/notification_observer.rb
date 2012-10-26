class NotificationObserver < ActiveRecord::Observer
  def after_create(notification)
    if notification.event.kind == 'motion_closing_soon'
      if notification.user.subscribed_to_proposal_closure_notifications
        UserMailer.motion_closing_soon(notification.user, notification.event.eventable).deliver!
      end
    end
  end
end
