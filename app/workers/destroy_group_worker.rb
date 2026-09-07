class DestroyGroupWorker < ApplicationJob
  # Archival alone is not deletion authority: restoring and later archiving a
  # group must invalidate the earlier job. Legacy jobs lack this proof and
  # need operator review before being rescheduled.
  def perform(group_id, archived_at = nil)
    unless archived_at
      Rails.logger.warn("Skipping legacy group deletion without an archive timestamp: #{group_id}")
      return
    end

    Group.transaction do
      Group.where(id: group_id, archived_at: archived_at).lock.first&.destroy!
    end
  end
end
