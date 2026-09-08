class DestroyGroupWorker < ApplicationJob
  # Discard alone is not deletion authority: restoring and later discarding a
  # group must invalidate the earlier job. Legacy jobs lack this proof and
  # need operator review before being rescheduled.
  def perform(group_id, discarded_at = nil)
    unless discarded_at
      Rails.logger.warn("Skipping legacy group deletion without a discard timestamp: #{group_id}")
      return
    end

    Group.transaction do
      Group.where(id: group_id, discarded_at: discarded_at).lock.first&.destroy!
    end
  end
end
