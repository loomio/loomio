class CleanupOrphanUsersWorker < ApplicationJob
  queue_as :low

  def self.enabled?
    AppConfig.orphan_user_deletion_after_days.present?
  end

  def perform
    days = AppConfig.orphan_user_deletion_after_days
    return unless days

    CleanupService.delete_inactive_orphan_users(inactive_before: days.days.ago)
  end
end
