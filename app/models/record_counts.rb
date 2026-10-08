module RecordCounts
  # Callback-free writes (update_all/insert_all/delete_all/import) must refresh
  # their derived counts in the same transaction. Counted sources: memberships,
  # polls, discussions, poll_templates, groups.parent_id,
  # topic_items.parent_id, topic_readers.topic_id/last_read_at, and versions.
  # Use the corresponding owner recount helpers for bulk writes.

  # Apply deltas in the caller's transaction. RETURNING synchronizes loaded
  # owners without saving their unrelated dirty attributes or touching them.
  # Sort owners so transfers acquire their row locks in a consistent order.
  def self.adjust!(model, deltas, records: [])
    connection = model.connection
    records_by_id = records.compact.group_by(&:id)
    deltas.keys.compact.sort.each do |id|
      changes = deltas.fetch(id).reject { |_, delta| delta.zero? }
      next if changes.empty?

      columns = changes.keys.map { |column| connection.quote_column_name(column) }
      assignments = changes.map do |column, delta|
        quoted = connection.quote_column_name(column)
        "#{quoted} = COALESCE(#{quoted}, 0) + #{Integer(delta)}"
      end
      # exec_query marks this as a write and clears Rails' query cache. A
      # select_one with UPDATE RETURNING could cache an identical increment.
      counts = connection.exec_query(<<~SQL.squish).first
        UPDATE #{connection.quote_table_name(model.table_name)}
        SET #{assignments.join(', ')} WHERE id = #{Integer(id)}
        RETURNING #{columns.join(', ')}
      SQL
      next unless counts

      records_by_id.fetch(id, []).each do |record|
        record.assign_attributes(counts)
        record.clear_attribute_changes(counts.keys)
      end
    end
  end

  # Update a count using its before/after owner IDs. Subtract the old
  # contribution and add the new one; nil means the record does not count.
  # An unchanged contribution issues no SQL.
  def self.update!(model, column, before:, after:, records: [])
    return if before == after

    deltas = {}
    deltas[before] = { column => -1 } if before
    deltas[after] = { column => 1 } if after
    adjust!(model, deltas, records: records)
  end

  # Bulk writers cannot use per-record deltas. Lock before reading so a recount
  # cannot overwrite a concurrent delta with an older snapshot of the children.
  def self.recount!(record)
    record.class.transaction do
      return unless record.class.where(id: record.id).lock('FOR NO KEY UPDATE').pick(:id)

      record.update_columns(yield)
    end
  end
end
