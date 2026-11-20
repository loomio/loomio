class CleanupGroupsWorker < ApplicationJob
  queue_as :low

  def self.enabled?
    ENV["LOOMIO_GROUP_CLEANUP_ENABLED"].present?
  end

  def perform
    return unless self.class.enabled?

    CleanupService.discard_unused_groups_and_warn_expired_trials
  end
end
