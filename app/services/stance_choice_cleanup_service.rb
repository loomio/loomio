# Stance choices join a stance to one option from the same poll. Historical
# corruption includes missing records, cross-poll joins, and repeated choices
# for one stance and option. Report those categories without mutation first;
# cleanup then retains the duplicate row matching the stance's cached visible
# score, removes invalid rows, and rebuilds every affected cache.
class StanceChoiceCleanupService
  SAMPLE_LIMIT = 20

  def self.report
    duplicate_counts = duplicate_choice_counts
    invalid_choice_ids = choice_ids_invalid
    stale_option_ids = stale_poll_option_ids

    {
      counts: {
        missing_stance: choices_missing_stance.count,
        missing_poll_option: choices_missing_poll_option.count,
        poll_mismatch: choices_with_poll_mismatch.count,
        duplicate_groups: duplicate_counts.fetch("groups").to_i,
        duplicate_extra_choices: duplicate_counts.fetch("extras").to_i,
        poll_options_missing_poll: poll_options_missing_poll.count,
        stale_poll_option_caches: stale_option_ids.length,
        invalid_choices_total: invalid_choice_ids.length
      },
      samples: {
        missing_stance_choice_ids: choices_missing_stance.limit(SAMPLE_LIMIT).ids,
        missing_poll_option_choice_ids: choices_missing_poll_option.limit(SAMPLE_LIMIT).ids,
        poll_mismatch_choice_ids: choices_with_poll_mismatch.limit(SAMPLE_LIMIT).ids,
        duplicate_choice_ids_to_remove: duplicate_choice_ids_to_remove.first(SAMPLE_LIMIT),
        poll_option_ids_missing_poll: poll_options_missing_poll.limit(SAMPLE_LIMIT).ids,
        stale_poll_option_cache_ids: stale_option_ids.first(SAMPLE_LIMIT)
      }
    }
  end

  def self.cleanup!
    StanceChoice.transaction do
      report_before = report
      choice_ids = choice_ids_invalid
      orphan_option_ids = poll_options_missing_poll.ids
      stale_option_ids = stale_poll_option_ids
      choice_ids |= StanceChoice.where(poll_option_id: orphan_option_ids).ids

      affected_stance_ids = StanceChoice.where(id: choice_ids).where.not(stance_id: nil).distinct.pluck(:stance_id)
      affected_poll_ids = affected_poll_ids(choice_ids)
      affected_poll_ids |= PollOption.where(id: stale_option_ids).distinct.pluck(:poll_id)

      StanceChoice.where(id: choice_ids).delete_all
      PollOption.where(id: orphan_option_ids).delete_all
      Stance.where(id: affected_stance_ids).find_each(&:update_option_scores!)
      Poll.where(id: affected_poll_ids).find_each(&:update_counts!)

      report_before.fetch(:counts).merge(
        removed_choices: choice_ids.length,
        removed_poll_options: orphan_option_ids.length,
        repaired_poll_option_caches: stale_option_ids.length,
        remaining: report.fetch(:counts)
      )
    end
  end

  def self.choices_missing_stance
    StanceChoice
      .joins("LEFT JOIN stances ON stances.id = stance_choices.stance_id")
      .where(stances: { id: nil })
  end

  def self.choices_missing_poll_option
    StanceChoice
      .joins("LEFT JOIN poll_options ON poll_options.id = stance_choices.poll_option_id")
      .where(poll_options: { id: nil })
  end

  def self.choices_with_poll_mismatch
    StanceChoice
      .joins(:stance, :poll_option)
      .where("stances.poll_id <> poll_options.poll_id")
  end

  def self.poll_options_missing_poll
    PollOption
      .joins("LEFT JOIN polls ON polls.id = poll_options.poll_id")
      .where(polls: { id: nil })
  end

  def self.choice_ids_invalid
    (
      choices_missing_stance.ids +
      choices_missing_poll_option.ids +
      choices_with_poll_mismatch.ids +
      duplicate_choice_ids_to_remove
    ).uniq
  end
  private_class_method :choice_ids_invalid

  def self.duplicate_choice_counts
    StanceChoice.connection.select_one(<<~SQL.squish)
      SELECT COUNT(*) AS groups, COALESCE(SUM(choice_count - 1), 0) AS extras
      FROM (
        SELECT COUNT(*) AS choice_count
        FROM stance_choices
        GROUP BY stance_id, poll_option_id
        HAVING COUNT(*) > 1
      ) duplicate_groups
    SQL
  end
  private_class_method :duplicate_choice_counts

  def self.duplicate_choice_ids_to_remove
    StanceChoice.connection.select_values(<<~SQL.squish).map(&:to_i)
      SELECT id
      FROM (
        SELECT stance_choices.id,
               ROW_NUMBER() OVER (
                 PARTITION BY stance_choices.stance_id, stance_choices.poll_option_id
                 ORDER BY
                   CASE
                     WHEN stances.option_scores ->> stance_choices.poll_option_id::text = stance_choices.score::text THEN 0
                     ELSE 1
                   END,
                   stance_choices.id DESC
               ) AS duplicate_rank
        FROM stance_choices
        INNER JOIN stances ON stances.id = stance_choices.stance_id
      ) ranked_choices
      WHERE duplicate_rank > 1
      ORDER BY id
    SQL
  end
  private_class_method :duplicate_choice_ids_to_remove

  def self.stale_poll_option_ids
    StanceChoice.connection.select_values(<<~SQL.squish).map(&:to_i)
      WITH expected AS (
        SELECT poll_options.id,
               COALESCE(SUM(stance_choices.score) FILTER (
                 WHERE stances.latest AND stances.revoked_at IS NULL
               ), 0) AS total_score,
               COUNT(stance_choices.id) FILTER (
                 WHERE stances.latest AND stances.revoked_at IS NULL
               ) AS voter_count,
               COALESCE(
                 jsonb_object_agg(stances.participant_id::text, stance_choices.score) FILTER (
                   WHERE stances.latest
                     AND stances.revoked_at IS NULL
                     AND stances.participant_id IS NOT NULL
                 ),
                 '{}'::jsonb
               ) AS voter_scores
        FROM poll_options
        INNER JOIN polls ON polls.id = poll_options.poll_id
        LEFT JOIN stance_choices ON stance_choices.poll_option_id = poll_options.id
        LEFT JOIN stances ON stances.id = stance_choices.stance_id
        WHERE polls.voting_system = 0
        GROUP BY poll_options.id
      )
      SELECT expected.id
      FROM expected
      INNER JOIN poll_options ON poll_options.id = expected.id
      WHERE poll_options.total_score <> expected.total_score
         OR poll_options.voter_count <> expected.voter_count
         OR poll_options.voter_scores <> expected.voter_scores
      ORDER BY expected.id
    SQL
  end
  private_class_method :stale_poll_option_ids

  def self.affected_poll_ids(choice_ids)
    return [] if choice_ids.empty?

    stance_poll_ids = StanceChoice
      .where(id: choice_ids)
      .joins(:stance)
      .distinct
      .pluck("stances.poll_id")
    option_poll_ids = StanceChoice
      .where(id: choice_ids)
      .joins(:poll_option)
      .distinct
      .pluck("poll_options.poll_id")
    (stance_poll_ids + option_poll_ids).compact.uniq
  end
  private_class_method :affected_poll_ids
end
