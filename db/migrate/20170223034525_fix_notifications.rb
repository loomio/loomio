class FixNotifications < ActiveRecord::Migration
  def change
    Notification.includes(event: :eventable).find_each(batch_size: 100) do |notification|
      next if notification.translation_values.blank? ||
              notification.translation_values[:title].present? ||
              !affected_event_kinds.include?(notification.kind)
      event = Events.const_get(notification.kind.camelize).new(notification.event.as_json) rescue Event.new
      notification.update(translation_values: event.send(:notification_translation_values))
    end
  end

  def affected_event_kinds
    %w(comment_liked
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
       user_mentioned).freeze
  end
end
