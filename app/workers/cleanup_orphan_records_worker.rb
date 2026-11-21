class CleanupOrphanRecordsWorker < ApplicationJob
  queue_as :low

  # Jobs from older deployments can still be retried from Solid Queue.
  def perform
  end
end
