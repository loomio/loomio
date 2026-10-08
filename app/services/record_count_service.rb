module RecordCountService
  # Apply deltas in the caller's transaction. RETURNING synchronizes loaded
  # owners without saving their unrelated dirty attributes or touching them.
  # Sort owners so transfers acquire their row locks in a consistent order.
  def self.adjust!(model, deltas, records: [])
    connection = model.connection
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

      records.select { |record| record.id == id }.each do |record|
        record.assign_attributes(counts)
        record.clear_attribute_changes(counts.keys)
      end
    end
  end

  def self.transfer!(model, column, from:, to:, amount: 1, records: [])
    deltas = Hash.new { |hash, id| hash[id] = { column => 0 } }
    deltas[from][column] -= amount if from
    deltas[to][column] += amount if to
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
