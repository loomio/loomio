class CleanupOrphanUsersWorker < ApplicationJob
  queue_as :low

  def self.enabled?
    ENV["LOOMIO_ORPHAN_USER_CLEANUP_ENABLED"].present?
  end

  def perform
    return unless self.class.enabled?

    CleanupService.delete_inactive_orphan_users
  end
end
