class WarnAndDiscardExpiredTrialGroupWorker < ApplicationJob
  queue_as :low

  def perform(group_id, only_unused: nil)
    enabled = only_unused.nil? ? ENV["CLEANUP_ENABLED"].present? : CleanupGroupsWorker.enabled?
    return unless enabled

    GroupService.warn_and_discard_expired_trial(group_id: group_id, only_unused: only_unused)
  end
end
