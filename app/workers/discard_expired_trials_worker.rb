class DiscardExpiredTrialsWorker < ApplicationJob
  queue_as :low

  def perform
    days = AppConfig.trial_discard_after_days
    return unless days

    TrialExpirationService.discard_unused_trials_and_warn_expired_trials(retention: days.days)
  end
end
