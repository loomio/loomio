class DestroyGroupWorker < ApplicationJob
  queue_as :group_destruction

  # Discard alone is not deletion authority: restoring and later discarding a
  # group must invalidate the earlier job. Legacy jobs lack this proof and
  # need operator review before being rescheduled. Recheck the current cleanup
  # switch and retention delay because both can change while a job is queued.
  def perform(group_id, discarded_at = nil)
    return unless ENV["CLEANUP_ENABLED"].present?

    unless discarded_at
      Rails.logger.warn("Skipping legacy group deletion without a discard timestamp: #{group_id}")
      return
    end

    Group.transaction do
      group = Group.where(id: group_id, discarded_at: discarded_at).lock.first
      next unless group
      next if group.discarded_at > Time.current - AppConfig.group_deletion_delay_days.days

      group.destroy!
    end
  end
end
