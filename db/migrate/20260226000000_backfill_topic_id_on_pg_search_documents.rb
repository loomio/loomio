class BackfillTopicIdOnPgSearchDocuments < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  BATCH_SIZE = 50_000

  def up
    # Delete orphaned search docs where the source record no longer exists
    execute <<~SQL
      DELETE FROM pg_search_documents WHERE searchable_type = 'Discussion'
        AND NOT EXISTS (SELECT 1 FROM discussions WHERE id = searchable_id)
    SQL
    execute <<~SQL
      DELETE FROM pg_search_documents WHERE searchable_type = 'Poll'
        AND NOT EXISTS (SELECT 1 FROM polls WHERE id = searchable_id)
    SQL
    execute <<~SQL
      DELETE FROM pg_search_documents WHERE searchable_type = 'Comment'
        AND NOT EXISTS (SELECT 1 FROM comments WHERE id = searchable_id)
    SQL
    execute <<~SQL
      DELETE FROM pg_search_documents WHERE searchable_type = 'Stance'
        AND NOT EXISTS (SELECT 1 FROM stances WHERE id = searchable_id)
    SQL
    execute <<~SQL
      DELETE FROM pg_search_documents WHERE searchable_type = 'Outcome'
        AND NOT EXISTS (SELECT 1 FROM outcomes WHERE id = searchable_id)
    SQL

    add_index :pg_search_documents, [:searchable_type, :id],
      order: { id: :desc },
      where: "topic_id IS NULL",
      name: "idx_psd_backfill",
      algorithm: :concurrently,
      if_not_exists: true

    backfill("Discussion", <<~SQL)
      UPDATE pg_search_documents
      SET topic_id = searchable_id
      WHERE searchable_type = 'Discussion'
        AND topic_id IS NULL
        AND id IN (
          SELECT id FROM pg_search_documents
          WHERE searchable_type = 'Discussion' AND topic_id IS NULL
          ORDER BY id DESC
          LIMIT #{BATCH_SIZE}
        )
    SQL

    backfill("Poll", <<~SQL)
      UPDATE pg_search_documents psd
      SET topic_id = p.topic_id
      FROM polls p
      WHERE psd.searchable_type = 'Poll'
        AND psd.searchable_id = p.id
        AND psd.topic_id IS NULL
        AND psd.id IN (
          SELECT id FROM pg_search_documents
          WHERE searchable_type = 'Poll' AND topic_id IS NULL
          ORDER BY id DESC
          LIMIT #{BATCH_SIZE}
        )
    SQL

    backfill("Comment", <<~SQL)
      UPDATE pg_search_documents psd
      SET topic_id = e.topic_id
      FROM events e
      WHERE psd.searchable_type = 'Comment'
        AND e.eventable_type = 'Comment'
        AND e.eventable_id = psd.searchable_id
        AND psd.topic_id IS NULL
        AND psd.id IN (
          SELECT id FROM pg_search_documents
          WHERE searchable_type = 'Comment' AND topic_id IS NULL
          ORDER BY id DESC
          LIMIT #{BATCH_SIZE}
        )
    SQL

    backfill("Stance", <<~SQL)
      UPDATE pg_search_documents psd
      SET topic_id = p.topic_id
      FROM stances s
        JOIN polls p ON p.id = s.poll_id
      WHERE psd.searchable_type = 'Stance'
        AND psd.searchable_id = s.id
        AND psd.topic_id IS NULL
        AND psd.id IN (
          SELECT id FROM pg_search_documents
          WHERE searchable_type = 'Stance' AND topic_id IS NULL
          ORDER BY id DESC
          LIMIT #{BATCH_SIZE}
        )
    SQL

    backfill("Outcome", <<~SQL)
      UPDATE pg_search_documents psd
      SET topic_id = p.topic_id
      FROM outcomes o
        JOIN polls p ON p.id = o.poll_id
      WHERE psd.searchable_type = 'Outcome'
        AND psd.searchable_id = o.id
        AND psd.topic_id IS NULL
        AND psd.id IN (
          SELECT id FROM pg_search_documents
          WHERE searchable_type = 'Outcome' AND topic_id IS NULL
          ORDER BY id DESC
          LIMIT #{BATCH_SIZE}
        )
    SQL

    remove_index :pg_search_documents, name: "idx_psd_backfill", if_exists: true
  end

  def down
    execute "UPDATE pg_search_documents SET topic_id = NULL"
  end

  private

  def backfill(type, sql)
    total = 0
    loop do
      result = execute(sql)
      rows = result.cmd_tuples
      total += rows
      say "  #{type}: #{total} rows updated so far", true
      break if rows == 0
    end
  end
end
