class WarnAndDiscardExpiredTrialGroupWorker < ApplicationJob
  queue_as :low

  def perform(group_id)
    return unless ENV["CLEANUP_ENABLED"].present?

    GroupService.warn_and_discard_expired_trial(group_id: group_id)
  end
end
