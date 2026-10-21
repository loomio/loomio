require 'test_helper'
require_relative '../../db/migrate/20261021000002_replace_email_failure_counters'

class ReplaceEmailFailureCountersTest < ActiveSupport::TestCase
  test 'legacy blocks survive without invented dates or delivery links' do
    connection = ActiveRecord::Base.connection
    schema = "suppression_migration_#{SecureRandom.hex(4)}"
    previous_path = connection.schema_search_path
    connection.execute("CREATE SCHEMA #{schema}")
    connection.schema_search_path = "#{schema}, public"
    migration = ReplaceEmailFailureCounters.new
    migration.suppress_messages do
      migration.create_table(:users) do |t|
        t.string :email
        t.integer :bounces_count, default: 0
        t.integer :complaints_count, default: 0
      end
      migration.create_table(:notification_delivery_events)
      connection.execute(<<~SQL)
        INSERT INTO #{schema}.users (email, bounces_count, complaints_count) VALUES
          (' MixedCase@Example.com ', 3, 2), ('clean@example.com', 0, 0), (NULL, 1, 1)
      SQL
      migration.up
    end
    records = connection.select_all("SELECT * FROM #{schema}.email_suppressions ORDER BY reason").to_a
    assert_equal %w[legacy_bounce legacy_complaint], records.map { |record| record.fetch('reason') }
    records.each do |record|
      assert_equal EmailSuppression.address_digest('mixedcase@example.com'), record.fetch('email_sha256')
      assert_nil record['occurred_at']
      assert_nil record['notification_delivery_event_id']
      assert_nil record['cleared_at']
    end
    assert_empty connection.columns("#{schema}.users").map(&:name) & %w[bounces_count complaints_count]
  ensure
    connection.schema_search_path = previous_path if previous_path
    connection.execute("DROP SCHEMA IF EXISTS #{schema} CASCADE") if schema
    connection.clear_cache!
  end
end
