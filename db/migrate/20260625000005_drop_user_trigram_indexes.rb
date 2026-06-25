# The trigram indexes added in 20260625000002 were never used in production
# (idx_scan = 0): the slow user-search query was driven by a Merge Join that
# scans the whole users table regardless of the index. The real fix is the
# query restructure (Topic#members two-arm UNION, driven from the small
# member/guest set), which doesn't need a trigram index. Reclaim the ~86 MB.
# pg_trgm is left installed (harmless, may be wanted later).
class DropUserTrigramIndexes < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_users_on_name_trgm"
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_users_on_username_trgm"
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_users_on_email_trgm"
  end

  def down
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_users_on_name_trgm ON users USING gin (name gin_trgm_ops)"
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_users_on_username_trgm ON users USING gin (username gin_trgm_ops)"
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS index_users_on_email_trgm ON users USING gin ((email::text) gin_trgm_ops)"
  end
end
