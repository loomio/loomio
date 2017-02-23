class FixNotifications < ActiveRecord::Migration
  def change
    Event.where(kind: %w(
      comment_liked
      comment_replied_to
      invitation_accepted
      membership_request_approved
      membership_requested
      motion_closed_by_user
      motion_closed
      motion_closing_soon
      motion_outcome_created
      new_coordinator
      user_added_to_group
      user_mentioned
    )).where('created_at > ?', 1.year.ago).find_each(batch_size: 100) do |event|
      e = Events.const_get(event.kind.camelize).new(event.as_json) rescue Event.new
      event.notifications.update_all(translation_values: e.send(:notification_translation_values)) rescue nil
    end
  end
end
