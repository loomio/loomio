class CleanupInactiveUsersWorker < ApplicationJob
  queue_as :low

  def perform
    InactiveUserCleanupService.destroy_orphan_users
  end
end
