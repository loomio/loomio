class CleanMalformedTopicReaderReadRanges < ActiveRecord::Migration[8.0]
  def up
    # Delete topic_readers whose read_ranges_string contains any non-'N-M'
    # token (legacy bad data). There are very few of these.
    result = execute(<<~SQL)
      DELETE FROM topic_readers
      WHERE read_ranges_string IS NOT NULL
        AND read_ranges_string != ''
        AND EXISTS (
          SELECT 1 FROM unnest(string_to_array(read_ranges_string, ',')) AS s
          WHERE s !~ '^\\d+-\\d+$'
        )
    SQL
    say "Deleted #{result.cmd_tuples} topic_readers with malformed read_ranges_string"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
