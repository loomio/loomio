class DestroyGroupWorker < ApplicationJob
  queue_as :group_destruction
  # The dispatcher writes to the same database inside its queue-cap transaction.
  self.enqueue_after_transaction_commit = false

  # Discard alone is not deletion authority: restoring and later discarding a
  # group must invalidate the earlier job. Legacy jobs lack this proof and
  # need operator review before being rescheduled. Recheck the current cleanup
  # switch and retention delay because both can change while a job is queued.
  def perform(group_id, discarded_at = nil)
    return unless AppConfig.discarded_group_deletion_after_days || AppConfig.discarded_subgroup_deletion_after_days

    unless discarded_at
      Rails.logger.warn("Skipping legacy group deletion without a discard timestamp: #{group_id}")
      return
    end

    Group.transaction do
      parent_id = Group.where(id: group_id, discarded_at: discarded_at).pick(:parent_id)
      Group.where(id: parent_id).lock.first if parent_id
      group = Group.where(id: group_id, discarded_at: discarded_at).lock.first
      next unless group
      subgroup_ids = group.all_subgroups.order(:id).lock.ids
      Subscription.lock.find_by(id: group.subscription_id)
      deletable = group.is_parent? ? PurgeService.deletable_discarded_groups : PurgeService.deletable_discarded_subgroups
      next unless deletable.exists?(id: group.id)

      destroy_with_versions!(group, [group.id, *subgroup_ids])
    end
  end

  private

  def destroy_with_versions!(group, group_ids)
    topic_ids = Topic.where(group_id: group_ids).order(:id).lock.ids

    # Take a snapshot of the versioned records owned by this tree while their
    # relationships still exist. The dependent associations destroy the records.
    record_ids = PurgeService.topic_version_record_ids(topic_ids).merge(
      Group => group_ids,
      Membership => Membership.where(group_id: group_ids).ids,
      PollTemplate => PollTemplate.where(group_id: group_ids).ids,
      DiscussionTemplate => DiscussionTemplate.where(group_id: group_ids).ids
    )

    PaperTrail.request(enabled: false) { group.destroy! }
    PurgeService.delete_destroyed_versions!(record_ids)
  end
end
