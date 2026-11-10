require 'test_helper'
require_relative '../../db/migrate/20261110000001_add_revoked_at_to_sessions'

class SessionRetentionTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'rolling back retention purges revoked credentials in batches while preserving active sessions' do
    connection = ActiveRecord::Base.connection
    original_path = connection.schema_search_path
    schema = "session_retention_#{SecureRandom.hex(6)}"
    connection.execute("CREATE SCHEMA #{connection.quote_table_name(schema)}")
    connection.schema_search_path = schema
    connection.create_table(:sessions)
    connection.create_table(:push_subscriptions) do |table|
      table.references :session, null: false, foreign_key: { on_delete: :cascade }
    end

    migration = AddRevokedAtToSessions.new
    migration.up
    assert connection.column_exists?(:sessions, :revoked_at)
    assert connection.index_exists?(:sessions, :revoked_at)

    connection.execute('INSERT INTO sessions (id) SELECT generate_series(1, 1006)')
    connection.execute('UPDATE sessions SET revoked_at = CURRENT_TIMESTAMP WHERE id <= 1005')
    connection.execute('INSERT INTO push_subscriptions (session_id) VALUES (1), (1006)')
    migration.down

    refute connection.column_exists?(:sessions, :revoked_at)
    assert_equal [ 1006 ], connection.select_values('SELECT id FROM sessions')
    assert_equal [ 1006 ], connection.select_values('SELECT session_id FROM push_subscriptions')
  ensure
    if connection && original_path
      connection.schema_search_path = original_path
      connection.execute("DROP SCHEMA IF EXISTS #{connection.quote_table_name(schema)} CASCADE") if schema
      connection.schema_cache.clear!
    end
  end
end
