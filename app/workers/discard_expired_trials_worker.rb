class DiscardExpiredTrialsWorker < ApplicationJob
  queue_as :low

  def self.enabled?
    AppConfig.trial_discard_after_days.present?
  end

  def perform
    days = AppConfig.trial_discard_after_days
    return unless days

    RetentionService.discard_unused_trials_and_warn_expired_trials(retention: days.days)
  end
end
