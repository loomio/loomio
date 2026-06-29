class MarkNotificationsAsReadWorker < ApplicationJob
  def perform(parent_type, parent_id, user_id)
    NotificationService.mark_as_read(parent_type, parent_id, user_id)
  end
end
