class DeleteVestigalEvents < ActiveRecord::Migration[5.2]
  def change
    delete_kinds = %w[poll_published group_published comment_liked invitation_resend outcome_published poll_published visitor_created visitor_reminded]
    # Event.where(kind: delete_kinds).count
    Event.where(kind: delete_kinds).delete_all
    # Notification.joins('LEFT OUTER JOIN events on events.id = notifications.event_id').
    #              where('events.id IS NULL').count
    Notification.joins('LEFT OUTER JOIN events on events.id = notifications.event_id').
                 where('events.id IS NULL').delete_all

  end
end
