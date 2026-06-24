# Speeds up the invite / @mention autocomplete search (User.invitable_search,
# MembershipQuery.search). That query ORs ILIKE across users.name, username and
# email, including a leading-wildcard pattern ("% q%") that no btree index can
# serve, so Postgres full-scans all ~485k users on every keystroke — the single
# largest consumer of DB time in production (pg_stat_statements, 2026-06-25).
#
# pg_trgm GIN indexes make both prefix ("q%") and substring ("% q%") ILIKE
# patterns index-accessible, letting the planner BitmapOr the three columns
# instead of scanning the table.
class AddTrigramIndexesToUsers < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def up
    enable_extension 'pg_trgm' unless extension_enabled?('pg_trgm')

    execute <<~SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_users_on_name_trgm
        ON users USING gin (name gin_trgm_ops)
    SQL
    execute <<~SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_users_on_username_trgm
        ON users USING gin (username gin_trgm_ops)
    SQL
    # email is citext; gin_trgm_ops is defined for text, so index the ::text cast.
    # The query must match this expression — see the email-clause change in the scope.
    execute <<~SQL
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_users_on_email_trgm
        ON users USING gin ((email::text) gin_trgm_ops)
    SQL
  end

  def down
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_users_on_name_trgm"
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_users_on_username_trgm"
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_users_on_email_trgm"
    # pg_trgm intentionally left enabled.
  end
end
