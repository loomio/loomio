class CleanupEmptyTrialsWorker < ApplicationJob
  queue_as :low

  def perform
    EmptyTrialCleanupService.delete!(io: $stdout)
  end
end
