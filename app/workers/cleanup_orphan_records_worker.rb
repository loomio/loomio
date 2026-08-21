class CleanupOrphanRecordsWorker < ApplicationJob
  queue_as :low

  def perform
    CleanupService.delete_orphan_records
  end
end
