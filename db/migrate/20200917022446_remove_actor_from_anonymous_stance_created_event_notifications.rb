class RemoveActorFromAnonymousStanceCreatedEventNotifications < ActiveRecord::Migration[5.2]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    poll_ids = Poll.where(anonymous: true).pluck(:id)
    stance_ids = Stance.where(poll_id: poll_ids).pluck(:id)
    event_ids = Event.where(kind: 'stance_created', eventable_id: stance_ids).pluck(:id)
    notification_ids = Notification.where(event_id: event_ids).pluck(:id)
    Notification.where(id: notification_ids).update_all(actor_id: nil)
  end
end
