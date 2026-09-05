class CleanMalformedTopicReaderReadRanges < ActiveRecord::Migration[8.0]
  def up
    # Read history is a cache; the reader also holds access and notification
    # preferences. Reset only the damaged cache, preserving those records.
    result = execute(<<~SQL)
      UPDATE topic_readers SET read_ranges_string = ''
      WHERE read_ranges_string IS NOT NULL
        AND read_ranges_string != ''
        AND EXISTS (
          SELECT 1 FROM unnest(string_to_array(read_ranges_string, ',')) AS s
          WHERE s !~ '^\\d+-\\d+$'
        )
    SQL
    say "Reset #{result.cmd_tuples} malformed topic reader read ranges"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
