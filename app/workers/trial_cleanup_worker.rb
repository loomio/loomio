class TrialCleanupWorker < ApplicationJob
  queue_as :low

  def perform
    TrialCleanupService.cleanup!
  end
end
