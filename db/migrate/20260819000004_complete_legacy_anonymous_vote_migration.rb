require_relative "support/legacy_anonymous_vote_migration_service"
require_relative "support/legacy_anonymous_vote_migration_cleanup_service"
require_relative "support/legacy_event_record"

# Complete the anonymous-voting transition before 3.3 removes its runtime
# compatibility code. This migration deliberately uses the 3.2 close semantics
# preserved here rather than the current Poll validations and service branches,
# so direct upgrades and upgrades paused on 3.2.0 follow the same data path.
class CompleteLegacyAnonymousVoteMigration < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    open_legacy_polls.find_each(order: :asc) do |poll|
      close_legacy_poll!(poll)
    end

    LegacyAnonymousVoteMigrationService.migrate_all!
  end

  def down
    # Closing and converting anonymous polls is intentionally one-way.
  end

  private

  def open_legacy_polls
    Poll.where(
      anonymous: true,
      voting_system: Poll.voting_systems.fetch("stance"),
      closed_at: nil
    )
  end

  def close_legacy_poll!(poll)
    Poll.transaction(requires_new: true) do
      poll.lock!
      next if poll.closed_at

      replace_stance_receipts!(poll)
      anonymize_stances!(poll)
      reveal_hidden_results!(poll)

      custom_fields = poll.custom_fields
      custom_fields = custom_fields.merge("stv_results" => StvCountService.count(poll)) if poll.poll_type == "stv"
      closed_at = Time.current
      poll.update_columns(closed_at: closed_at, custom_fields: custom_fields, updated_at: closed_at)
      poll.topic.update_active_polls_count

      ReindexPollWorker.perform_later(poll.id)
      publish_poll_expired!(poll)
    end

    PollService.publish_topic_if_active(poll)
  end

  def replace_stance_receipts!(poll)
    StanceReceipt.where(poll_id: poll.id).delete_all
    rows = poll.stances.latest.map do |stance|
      {
        poll_id: poll.id,
        voter_id: stance.participant_id,
        inviter_id: stance.inviter_id,
        invited_at: stance.created_at,
        vote_cast: poll.quorum_reached? ? !!stance.cast_at : nil
      }
    end
    StanceReceipt.insert_all(rows) if rows.any?
  end

  # Preserve the 3.2 poll-close notification using migration-owned table models.
  # Direct upgrades may run before or after the self-contained notification
  # fields have been introduced, so populate those fields when they exist while
  # retaining event_id until the cutover migration verifies the backfill.
  def publish_poll_expired!(poll)
    event = LegacyEventRecord.create!(
      kind: "poll_expired",
      eventable_type: "Poll",
      eventable_id: poll.id,
      user_id: poll.author_id,
      created_at: poll.closed_at,
      updated_at: poll.closed_at
    )

    attributes = {
      event_id: event.id,
      user_id: poll.author_id,
      actor_id: poll.author_id,
      viewed: false,
      created_at: poll.closed_at,
      updated_at: poll.closed_at
    }
    if LegacyNotificationRecord.column_names.include?("deduplication_key")
      attributes.merge!(
        kind: "poll_expired",
        subject_type: "Poll",
        subject_id: poll.id,
        deduplication_key: "event:#{event.id}"
      )
    end
    LegacyNotificationRecord.create!(attributes)
  end

  def anonymize_stances!(poll)
    stance_ids = poll.stances.select(:id)
    LegacyEventRecord.where(eventable_type: "Stance", eventable_id: stance_ids).update_all(user_id: nil)
    poll.stances.update_all(participant_id: nil)
  end

  def reveal_hidden_results!(poll)
    return unless poll.topic && poll.hide_results == "until_closed"

    stance_ids = poll.stances.latest.reject(&:body_is_blank?).map(&:id)
    LegacyEventRecord.where(kind: "stance_created", eventable_id: stance_ids, topic_id: nil).update_all(topic_id: poll.topic.id)
    LegacyTopicEventRepairService.repair!(poll.topic_id)
  end
end
