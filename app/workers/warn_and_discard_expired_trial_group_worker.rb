class WarnAndDiscardExpiredTrialGroupWorker < ApplicationJob
  queue_as :low

  def perform(group_id, only_unused: nil)
    days = AppConfig.trial_discard_after_days
    # Older jobs without this argument used the retired cleanup path.
    return unless days && only_unused == false

    GroupService.warn_and_discard_expired_trial(group_id: group_id, retention: days.days)
  end
end
