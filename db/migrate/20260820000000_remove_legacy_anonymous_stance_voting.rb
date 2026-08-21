class RemoveLegacyAnonymousStanceVoting < ActiveRecord::Migration[8.1]
  CONSTRAINT_NAME = "polls_anonymous_voting_system"

  def up
    # Refuse the runtime-code removal until every poll uses exactly one of the
    # supported storage models. Report the bad rows before adding the database
    # constraint so operators receive an actionable upgrade error.
    legacy_poll_count = select_value(<<~SQL.squish).to_i
      SELECT COUNT(*)
      FROM polls
      WHERE anonymous = TRUE
        AND voting_system = 0
    SQL

    if legacy_poll_count.positive?
      legacy_poll_ids = select_values(<<~SQL.squish)
        SELECT id
        FROM polls
        WHERE anonymous = TRUE
          AND voting_system = 0
        ORDER BY id
        LIMIT 20
      SQL
      raise ActiveRecord::MigrationError,
            "Loomio 3.3 could not complete the legacy anonymous poll conversion. " \
            "Found #{legacy_poll_count} remaining poll(s); first IDs: #{legacy_poll_ids.join(', ')}"
    end

    identified_anonymous_ballot_count = select_value(<<~SQL.squish).to_i
      SELECT COUNT(*)
      FROM polls
      WHERE anonymous = FALSE
        AND voting_system = 1
    SQL

    if identified_anonymous_ballot_count.positive?
      identified_anonymous_ballot_ids = select_values(<<~SQL.squish)
        SELECT id
        FROM polls
        WHERE anonymous = FALSE
          AND voting_system = 1
        ORDER BY id
        LIMIT 20
      SQL
      raise ActiveRecord::MigrationError,
            "Anonymous-ballot voting requires anonymous polls. " \
            "Found #{identified_anonymous_ballot_count} identified poll(s) using anonymous-ballot storage; " \
            "first IDs: #{identified_anonymous_ballot_ids.join(', ')}"
    end

    execute <<~SQL.squish
      DELETE FROM solid_queue_jobs
      WHERE class_name = 'MigrateLegacyAnonymousVotesWorker'
    SQL

    add_check_constraint :polls,
                         "(anonymous = TRUE AND voting_system = 1) OR (anonymous = FALSE AND voting_system = 0)",
                         name: CONSTRAINT_NAME,
                         validate: false
    # Validate separately so PostgreSQL does not hold an access-exclusive lock
    # while it scans existing polls.
    validate_check_constraint :polls, name: CONSTRAINT_NAME
  end

  def down
    remove_check_constraint :polls, name: CONSTRAINT_NAME
  end
end
