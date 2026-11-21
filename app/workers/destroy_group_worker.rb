class DestroyGroupWorker < ApplicationJob
  queue_as :group_destruction
  # The dispatcher writes to the same database inside its queue-cap transaction.
  self.enqueue_after_transaction_commit = false

  def self.enabled?
    AppConfig.discarded_group_deletion_after_days.present?
  end

  # Discard alone is not deletion authority: restoring and later discarding a
  # group must invalidate the earlier job. Legacy jobs lack this proof and
  # need operator review before being rescheduled. Recheck the current cleanup
  # switch and retention delay because both can change while a job is queued.
  def perform(group_id, discarded_at = nil)
    return unless self.class.enabled?

    unless discarded_at
      Rails.logger.warn("Skipping legacy group deletion without a discard timestamp: #{group_id}")
      return
    end

    Group.transaction do
      group = Group.parents_only.where(id: group_id, discarded_at: discarded_at).lock.first
      next unless group
      CleanupService.descendant_groups(group.id).order(:id).lock.ids
      Subscription.lock.find_by(id: group.subscription_id)
      next unless CleanupService.deletable_discarded_groups.exists?(id: group.id)

      Current.set(permanently_deleting_group: true) do
        PaperTrail.request(enabled: false) { group.destroy! }
      end
    end
  end
end
