class CleanupTrialGroupsWorker < ApplicationJob
  queue_as :low
  WARNING_LIMIT = 100

  def perform
    return unless ENV["CLEANUP_ENABLED"].present?

    TrialGroupCleanupService.run!(io: $stdout, warning_limit: WARNING_LIMIT)
  end
end
