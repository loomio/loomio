class WarnExpiredSubscriptionGroupsWorker < ApplicationJob
  queue_as :low
  BATCH_SIZE = 100

  def perform
    ExpiredSubscriptionGroupCleanupService.warn_and_schedule!(io: $stdout, limit: BATCH_SIZE)
  end
end
