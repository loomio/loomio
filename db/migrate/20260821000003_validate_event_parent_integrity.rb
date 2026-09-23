require_relative "support/legacy_topic_event_repair_service"

class ValidateEventParentIntegrity < ActiveRecord::Migration[8.1]
  def up
    count_previous = nil
    loop do
      rows = select_rows(<<~SQL)
        SELECT child.topic_id, COUNT(*)
        FROM events child
        LEFT JOIN events parent ON parent.id = child.parent_id
        WHERE child.parent_id IS NOT NULL
          AND parent.id IS NULL
          AND child.topic_id IS NOT NULL
        GROUP BY child.topic_id
      SQL
      break if rows.empty?

      count = rows.sum { |_topic_id, row_count| row_count.to_i }
      if count == count_previous
        raise "event parent repair made no progress with #{count} dangling rows"
      end

      rows.each { |topic_id, _row_count| LegacyTopicEventRepairService.repair!(topic_id) }
      count_previous = count
    end

    validate_foreign_key :events, :events, column: :parent_id
  end

  def down
    # Validation does not change the shape of the foreign key.
  end
end
