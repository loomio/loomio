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
      descendant_ids = CleanupService.descendant_groups(group.id).order(:id).lock.ids
      Subscription.lock.find_by(id: group.subscription_id)
      next unless CleanupService.deletable_discarded_groups.exists?(id: group.id)

      destroy_with_versions!(group, [group.id, *descendant_ids])
    end
  end

  private

  def destroy_with_versions!(group, group_ids)
    topic_ids = Topic.where(group_id: group_ids).order(:id).lock.ids
    discussions = Discussion.where(topic_id: topic_ids)
    polls = Poll.where(topic_id: topic_ids)
    stances = Stance.where(poll_id: polls.select(:id))
    outcomes = Outcome.where(poll_id: polls.select(:id))
    comments = Comment.under_parents(discussions, polls, stances, outcomes)

    # Take a snapshot of the versioned records owned by this tree while their
    # relationships still exist. The dependent associations destroy the records.
    record_ids = { Group => group_ids, Topic => topic_ids }
    scopes = [discussions, polls, stances, outcomes, comments, Membership.where(group_id: group_ids),
              PollTemplate.where(group_id: group_ids), DiscussionTemplate.where(group_id: group_ids)]
    scopes.each { |scope| record_ids[scope.klass] = scope.ids }

    PaperTrail.request(enabled: false) { group.destroy! }

    record_ids.each do |model, ids|
      next if ids.empty?

      # Preserve history for any record that survived the cascade. This also
      # includes events filtered out of the normal history view.
      survivors = model.unscoped.where(id: ids).select(:id)
      PaperTrail::Version.where(item_type: model.polymorphic_name, item_id: ids).where.not(item_id: survivors).delete_all
    end
  end
end
