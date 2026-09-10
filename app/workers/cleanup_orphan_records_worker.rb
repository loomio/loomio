class CleanupOrphanRecordsWorker < ApplicationJob
  queue_as :low

  def perform
    return unless ENV["CLEANUP_ENABLED"].present?

    CleanupService.delete_orphan_records
    CleanupService.delete_inactive_orphan_users
  end
end
