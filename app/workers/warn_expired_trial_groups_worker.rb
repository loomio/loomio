class WarnExpiredTrialGroupsWorker < ApplicationJob
  queue_as :low
  BATCH_SIZE = 100

  def perform
    ExpiredTrialGroupCleanupService.warn_and_schedule!(io: $stdout, limit: BATCH_SIZE)
  end
end
