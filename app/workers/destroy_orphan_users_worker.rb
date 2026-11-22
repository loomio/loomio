class DestroyOrphanUsersWorker < ApplicationJob
  queue_as :low

  def perform
    days = AppConfig.orphan_user_deletion_after_days
    return unless days

    RetentionService.destroy_inactive_orphan_users(inactive_before: days.days.ago)
  end
end
