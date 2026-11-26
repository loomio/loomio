class DestroyTopicWorker < ApplicationJob
  queue_as :group_destruction
  # The dispatcher writes to the same database inside its queue-cap transaction.
  self.enqueue_after_transaction_commit = false

  # Discard alone is not deletion authority: restoring and later discarding a
  # thread must invalidate the earlier job. Recheck the current retention delay
  # because it can change while a job is queued.
  def perform(topic_id, discarded_at = nil)
    return unless AppConfig.discarded_thread_deletion_after_days
    return unless discarded_at

    Topic.transaction do
      group_id = Topic.where(id: topic_id, discarded_at: discarded_at).pick(:group_id)
      Group.where(id: group_id).lock.first if group_id
      topic = Topic.where(id: topic_id, discarded_at: discarded_at).lock.first
      next unless topic
      next unless PurgeService.deletable_discarded_threads.exists?(id: topic.id)

      destroy_with_versions!(topic)
    end
  end

  private

  def destroy_with_versions!(topic)
    record_ids = PurgeService.topic_version_record_ids([topic.id])
    PurgeService.delete_anonymous_ballots_for_topics!([topic.id])
    PaperTrail.request(enabled: false) { topic.destroy! }
    PurgeService.delete_destroyed_versions!(record_ids)
  end
end
