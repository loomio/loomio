class CleanupTrialGroupsWorker < ApplicationJob
  queue_as :low
  WARNING_LIMIT = 100

  def perform
    TrialGroupCleanupService.run!(io: $stdout, warning_limit: WARNING_LIMIT)
  end
end
