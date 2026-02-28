class BackfillTopicIdOnPgSearchDocuments < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  BATCH_SIZE = 100_000

  def up
    # Delete orphaned search docs where the source record no longer exists
    %w[Discussion Poll Comment Stance Outcome].each do |type|
      table = type.tableize
      say "Deleting orphaned #{type} search docs..."
      execute <<~SQL
        DELETE FROM pg_search_documents
        WHERE searchable_type = '#{type}'
          AND NOT EXISTS (SELECT 1 FROM #{table} WHERE id = searchable_id)
      SQL
    end

    # Discussion: topic_id = searchable_id (no join needed, single UPDATE)
    say "Backfilling Discussion topic_ids..."
    execute <<~SQL
      UPDATE pg_search_documents
      SET topic_id = searchable_id
      WHERE searchable_type = 'Discussion'
        AND topic_id IS NULL
    SQL

    # Poll: join polls to get topic_id
    say "Backfilling Poll topic_ids..."
    backfill_with_join("Poll", <<~SQL)
      UPDATE pg_search_documents psd
      SET topic_id = p.topic_id
      FROM polls p
      WHERE psd.searchable_type = 'Poll'
        AND psd.searchable_id = p.id
        AND psd.topic_id IS NULL
        AND psd.id BETWEEN :min_id AND :max_id
    SQL

    # Comment: join events to get topic_id
    say "Backfilling Comment topic_ids..."
    backfill_with_join("Comment", <<~SQL)
      UPDATE pg_search_documents psd
      SET topic_id = e.topic_id
      FROM events e
      WHERE psd.searchable_type = 'Comment'
        AND e.eventable_type = 'Comment'
        AND e.eventable_id = psd.searchable_id
        AND psd.topic_id IS NULL
        AND psd.id BETWEEN :min_id AND :max_id
    SQL

    # Stance: join stances → polls to get topic_id
    say "Backfilling Stance topic_ids..."
    backfill_with_join("Stance", <<~SQL)
      UPDATE pg_search_documents psd
      SET topic_id = p.topic_id
      FROM stances s
        JOIN polls p ON p.id = s.poll_id
      WHERE psd.searchable_type = 'Stance'
        AND psd.searchable_id = s.id
        AND psd.topic_id IS NULL
        AND psd.id BETWEEN :min_id AND :max_id
    SQL

    # Outcome: join outcomes → polls to get topic_id
    say "Backfilling Outcome topic_ids..."
    backfill_with_join("Outcome", <<~SQL)
      UPDATE pg_search_documents psd
      SET topic_id = p.topic_id
      FROM outcomes o
        JOIN polls p ON p.id = o.poll_id
      WHERE psd.searchable_type = 'Outcome'
        AND psd.searchable_id = o.id
        AND psd.topic_id IS NULL
        AND psd.id BETWEEN :min_id AND :max_id
    SQL

    remove_index :pg_search_documents, name: "idx_psd_backfill", if_exists: true
  end

  def down
    execute "UPDATE pg_search_documents SET topic_id = NULL"
  end

  private

  def backfill_with_join(type, sql_template)
    max_id = execute("SELECT MAX(id) FROM pg_search_documents WHERE searchable_type = '#{type}'").first["max"].to_i
    min_id = execute("SELECT MIN(id) FROM pg_search_documents WHERE searchable_type = '#{type}'").first["min"].to_i
    return if max_id == 0

    total = 0
    cursor = min_id
    while cursor <= max_id
      batch_max = cursor + BATCH_SIZE - 1
      sql = sql_template.gsub(":min_id", cursor.to_s).gsub(":max_id", batch_max.to_s)
      result = execute(sql)
      rows = result.cmd_tuples
      total += rows
      say "  #{type}: #{total} rows updated (ids #{cursor}..#{batch_max})", true
      cursor = batch_max + 1
    end
  end
end
