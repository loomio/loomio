# Drops indexes reported with idx_scan = 0 in production (pg_stat_statements /
# pg_stat_user_indexes, 2026-06-25), reclaiming ~1.2 GB and removing write
# overhead. Each is gated with IF EXISTS and recreated in #down.
#
# Review note: index_events_on_parent_id currently has 0 scans, but the
# topic/parent-chain work may start using events.parent_id — confirm before
# shipping this one. The pg_search authored_at indexes back date-sorted search
# results, which appear unused; keep them if you plan to enable that sort.
class DropUnusedIndexes < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_notifications_on_id"             # 304 MB, duplicates PK
    execute "DROP INDEX CONCURRENTLY IF EXISTS pg_search_documents_authored_at_asc_index"   # 292 MB
    execute "DROP INDEX CONCURRENTLY IF EXISTS pg_search_documents_authored_at_desc_index"  # 291 MB
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_events_on_parent_id"             # 148 MB
  end

  def down
    execute <<~SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_notifications_on_id
        ON notifications USING btree (id)
    SQL
    execute <<~SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS pg_search_documents_authored_at_asc_index
        ON pg_search_documents USING btree (authored_at ASC NULLS LAST)
    SQL
    execute <<~SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS pg_search_documents_authored_at_desc_index
        ON pg_search_documents USING btree (authored_at DESC NULLS LAST)
    SQL
    execute <<~SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_events_on_parent_id
        ON events USING btree (parent_id)
    SQL
  end
end
