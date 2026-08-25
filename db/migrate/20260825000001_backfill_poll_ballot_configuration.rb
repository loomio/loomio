class BackfillPollBallotConfiguration < ActiveRecord::Migration[8.1]
  INTEGER_PATTERN = "^[[:space:]]*[+-]?[0-9]+[[:space:]]*$"
  INTEGER_MIN = -2_147_483_648
  INTEGER_MAX = 2_147_483_647

  def up
    # These settings predate their first-class columns. Verify the legacy JSON
    # before copying it so an unexpected value cannot silently change how an
    # existing poll is interpreted.
    invalid_rows = select_all(<<~SQL.squish)
      SELECT polls.id, legacy.key, legacy.value
      FROM polls
      CROSS JOIN LATERAL (
        VALUES
          ('min_score', polls.min_score, polls.custom_fields ->> 'min_score'),
          ('max_score', polls.max_score, polls.custom_fields ->> 'max_score'),
          ('dots_per_person', polls.dots_per_person, polls.custom_fields ->> 'dots_per_person'),
          ('minimum_stance_choices', polls.minimum_stance_choices, polls.custom_fields ->> 'minimum_stance_choices'),
          ('maximum_stance_choices', polls.maximum_stance_choices, polls.custom_fields ->> 'maximum_stance_choices')
      ) AS legacy(key, column_value, value)
      WHERE polls.custom_fields ? legacy.key
        AND legacy.column_value IS NULL
        AND NULLIF(BTRIM(legacy.value), '') IS NOT NULL
        AND NOT CASE
          WHEN legacy.value ~ '#{INTEGER_PATTERN}'
          THEN legacy.value::numeric BETWEEN #{INTEGER_MIN} AND #{INTEGER_MAX}
          ELSE FALSE
        END
      ORDER BY polls.id, legacy.key
      LIMIT 20
    SQL

    if invalid_rows.any?
      details = invalid_rows.map { |row| "poll #{row.fetch('id')} #{row.fetch('key')}=#{row.fetch('value').inspect}" }.join(", ")
      raise ActiveRecord::MigrationError, "Invalid legacy poll ballot configuration: #{details}"
    end

    # A populated column was already authoritative. Otherwise copy a valid
    # integer, treating JSON null and blank strings as absent. The legacy JSON
    # remains stored but application accessors no longer consult it.
    execute <<~SQL.squish
      UPDATE polls
      SET min_score = COALESCE(min_score, NULLIF(BTRIM(custom_fields ->> 'min_score'), '')::integer),
          max_score = COALESCE(max_score, NULLIF(BTRIM(custom_fields ->> 'max_score'), '')::integer),
          dots_per_person = COALESCE(dots_per_person, NULLIF(BTRIM(custom_fields ->> 'dots_per_person'), '')::integer),
          minimum_stance_choices = COALESCE(minimum_stance_choices, NULLIF(BTRIM(custom_fields ->> 'minimum_stance_choices'), '')::integer),
          maximum_stance_choices = COALESCE(maximum_stance_choices, NULLIF(BTRIM(custom_fields ->> 'maximum_stance_choices'), '')::integer)
      WHERE (min_score IS NULL AND NULLIF(BTRIM(custom_fields ->> 'min_score'), '') IS NOT NULL)
         OR (max_score IS NULL AND NULLIF(BTRIM(custom_fields ->> 'max_score'), '') IS NOT NULL)
         OR (dots_per_person IS NULL AND NULLIF(BTRIM(custom_fields ->> 'dots_per_person'), '') IS NOT NULL)
         OR (minimum_stance_choices IS NULL AND NULLIF(BTRIM(custom_fields ->> 'minimum_stance_choices'), '') IS NOT NULL)
         OR (maximum_stance_choices IS NULL AND NULLIF(BTRIM(custom_fields ->> 'maximum_stance_choices'), '') IS NOT NULL)
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Legacy poll ballot configuration cannot be reconstructed"
  end
end
