class LegacyAnonymousVoteMigrationAuditService
  def self.audit(dangling_baseline: nil)
    detached_polls = Poll.where(voting_system: :anonymous_ballot).where.not(closed_at: nil).includes(
      :anonymous_ballots,
      :anonymous_ballot_choices,
      :poll_options
    )

    dangling_counts = dangling_stance_reference_counts
    errors = {
      detached_poll_invariants: detached_poll_invariant_errors(detached_polls),
      detached_poll_results: detached_poll_result_errors(detached_polls),
      legacy_reasons: legacy_reason_errors,
      dangling_stance_reference_increases: dangling_reference_increases(dangling_counts, dangling_baseline)
    }
    errors.delete_if { |_name, value| value.blank? }

    {
      ok: errors.empty?,
      counts: {
        detached_polls: detached_polls.length,
        detached_votes: AnonymousBallot.joins(:poll).where(polls: {voting_system: Poll.voting_systems.fetch("anonymous_ballot")}).count,
        legacy_reasons: LegacyAnonymousVoteReason.count,
        closed_polls_remaining: LegacyAnonymousVoteMigrationService.eligible_poll_scope.count,
        open_polls_remaining: Poll.where(anonymous: true, voting_system: :stance, closed_at: nil).count,
        stance_polls_remaining_total: Poll.where(anonymous: true, voting_system: :stance).count
      },
      dangling_stance_reference_counts: dangling_counts,
      errors: errors
    }
  end

  def self.reference_baseline
    dangling_stance_reference_counts
  end

  def self.dangling_reference_increases(counts, baseline)
    return {baseline: "not supplied"} if baseline.nil?

    counts.each_with_object({}) do |(name, count), increases|
      previous_count = baseline.fetch(name.to_s, baseline.fetch(name, 0)).to_i
      increases[name] = {baseline: previous_count, current: count} if count > previous_count
    end
  end
  private_class_method :dangling_reference_increases

  def self.detached_poll_invariant_errors(polls)
    polls.filter_map do |poll|
      failures = []
      failures << "not anonymous" unless poll.anonymous?
      failures << "not detached" unless poll.detached_anonymous?
      failures << "not closed" unless poll.closed?
      failures << "#{poll.stances.count} stances remain" if poll.stances.exists?
      next if failures.empty?

      {poll_id: poll.id, failures: failures}
    end
  end
  private_class_method :detached_poll_invariant_errors

  def self.detached_poll_result_errors(polls)
    polls.filter_map do |poll|
      option_data = poll.anonymous_ballot_choices
                        .group(:poll_option_id)
                        .pluck(
                          :poll_option_id,
                          Arel.sql("SUM(score)"),
                          Arel.sql("COUNT(DISTINCT anonymous_ballot_id)")
                        )
                        .to_h { |option_id, score, voters| [option_id, [score.to_i, voters.to_i]] }
      failures = []
      failures << "submitted vote count differs" unless poll.anonymous_ballots.length == poll.decided_voters_count
      failures << "none-of-the-above count differs" unless poll.anonymous_ballots.count(&:none_of_the_above?) == poll.none_of_the_above_count

      poll.poll_options.each do |option|
        score, voters = option_data.fetch(option.id, [0, 0])
        failures << "option #{option.id} score differs" unless score == option.total_score
        failures << "option #{option.id} voter count differs" unless voters == option.voter_count
      end

      if poll.poll_type == "stv" && StvCountService.count(poll).deep_stringify_keys != poll.stv_results.to_h.deep_stringify_keys
        failures << "STV result differs"
      end
      next if failures.empty?

      {poll_id: poll.id, failures: failures}
    end
  end
  private_class_method :detached_poll_result_errors

  def self.legacy_reason_errors
    LegacyAnonymousVoteReason.includes(anonymous_ballot: :poll).filter_map do |reason|
      ballot = reason.anonymous_ballot
      poll = ballot&.poll
      failures = []
      failures << "blank body" if reason.body.blank?
      failures << "detached vote is missing" unless ballot
      failures << "poll is missing" if ballot && !poll
      failures << "poll is not detached anonymous" if poll && !poll.detached_anonymous?
      failures << "poll is not closed" if poll && !poll.closed?
      next if failures.empty?

      {poll_id: poll&.id, failures: failures}
    end
  end
  private_class_method :legacy_reason_errors

  def self.dangling_stance_reference_counts
    {
      stance_choices: dangling_count("stance_choices", "stance_id"),
      comments: dangling_polymorphic_count("comments", "parent_type", "parent_id"),
      events: dangling_polymorphic_count("events", "eventable_type", "eventable_id"),
      event_parents: dangling_foreign_count("events", "parent_id", "events"),
      notifications: dangling_foreign_count("notifications", "event_id", "events"),
      reactions: dangling_polymorphic_count("reactions", "reactable_type", "reactable_id"),
      bookmarks: dangling_polymorphic_count("bookmarks", "bookmarkable_type", "bookmarkable_id"),
      tasks: dangling_polymorphic_count("tasks", "record_type", "record_id"),
      tasks_users: dangling_foreign_count("tasks_users", "task_id", "tasks"),
      translations: dangling_polymorphic_count("translations", "translatable_type", "translatable_id"),
      versions: dangling_polymorphic_count("versions", "item_type", "item_id"),
      search_documents: dangling_polymorphic_count("pg_search_documents", "searchable_type", "searchable_id"),
      attachments: dangling_polymorphic_count("active_storage_attachments", "record_type", "record_id"),
      announcement_stance_ids: dangling_announcement_stance_id_count
    }.reject { |_name, count| count.zero? }
  end
  private_class_method :dangling_stance_reference_counts

  def self.dangling_count(table, id_column)
    connection = ActiveRecord::Base.connection
    table_name = connection.quote_table_name(table)
    column_name = connection.quote_column_name(id_column)
    connection.select_value(<<~SQL.squish).to_i
      SELECT COUNT(*)
      FROM #{table_name} records
      LEFT JOIN stances ON stances.id = records.#{column_name}
      WHERE records.#{column_name} IS NOT NULL
        AND stances.id IS NULL
    SQL
  end
  private_class_method :dangling_count

  def self.dangling_polymorphic_count(table, type_column, id_column)
    connection = ActiveRecord::Base.connection
    table_name = connection.quote_table_name(table)
    type_name = connection.quote_column_name(type_column)
    id_name = connection.quote_column_name(id_column)
    connection.select_value(<<~SQL.squish).to_i
      SELECT COUNT(*)
      FROM #{table_name} records
      LEFT JOIN stances ON stances.id = records.#{id_name}
      WHERE records.#{type_name} = 'Stance'
        AND stances.id IS NULL
    SQL
  end
  private_class_method :dangling_polymorphic_count

  def self.dangling_foreign_count(table, id_column, parent_table)
    connection = ActiveRecord::Base.connection
    table_name = connection.quote_table_name(table)
    column_name = connection.quote_column_name(id_column)
    parent_name = connection.quote_table_name(parent_table)
    connection.select_value(<<~SQL.squish).to_i
      SELECT COUNT(*)
      FROM #{table_name} records
      LEFT JOIN #{parent_name} parents ON parents.id = records.#{column_name}
      WHERE records.#{column_name} IS NOT NULL
        AND parents.id IS NULL
    SQL
  end
  private_class_method :dangling_foreign_count

  def self.dangling_announcement_stance_id_count
    Event.where("custom_fields ? 'stance_ids'").sum do |event|
      stance_ids = Array(event.custom_fields["stance_ids"]).map(&:to_i)
      stance_ids.length - Stance.where(id: stance_ids).count
    end
  end
  private_class_method :dangling_announcement_stance_id_count
end
