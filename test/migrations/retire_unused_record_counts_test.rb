require 'test_helper'
require_relative '../../db/migrate/20261009000000_retire_unused_record_counts'

class RetireUnusedRecordCountsTest < ActiveSupport::TestCase
  test 'retiring unused counters preserves retained counts without rewriting records' do
    connection = ActiveRecord::Base.connection
    migration = RetireUnusedRecordCounts.new
    retired_columns = {
      groups: %i[closed_polls_count delegates_count discussion_templates_count subgroups_count],
      topics: %i[anonymous_polls_count closed_polls_count members_count],
      tags: %i[taggings_count]
    }
    migration.suppress_messages do
      retired_columns.each do |table, columns|
        columns.each { |column| migration.add_column(table, column, :integer, default: 0, null: false) }
      end
    end
    connection.clear_cache!

    # Even historical drift is preserved: deployment must not scan or rewrite
    # count owners. Separate count maintenance can repair such records later.
    groups(:group).update_column(:memberships_count, 999)
    comments(:public_discussion_comment).update_column(:versions_count, 999)
    tables = %w[groups users topics topic_items discussions comments outcomes tags]
    rows_before = tables.to_h do |table|
      [table, connection.select_rows("SELECT id, ctid::text FROM #{table} ORDER BY id")]
    end

    migration.suppress_messages { migration.up }
    connection.clear_cache!

    tables.each do |table|
      assert_equal rows_before.fetch(table),
        connection.select_rows("SELECT id, ctid::text FROM #{table} ORDER BY id"), table
    end
    assert_equal 999, groups(:group).reload.memberships_count
    assert_equal 999, comments(:public_discussion_comment).reload.versions_count
    retired_columns.each do |table, columns|
      assert_empty connection.columns(table).map(&:name) & columns.map(&:to_s), table
    end
  end
end
