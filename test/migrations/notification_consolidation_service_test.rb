require "test_helper"
require Rails.root.join("db/migrate/support/notification_consolidation_service")
require Rails.root.join("db/migrate/20260823000002_cut_over_events_to_topic_items")

class NotificationConsolidationServiceTest < ActiveSupport::TestCase
  test "repair recovers a legacy receipt that committed below the cursor" do
    with_preparation_schema do |connection|
      topic_item = connection.select_one(<<~SQL.squish)
        SELECT id, user_id, created_at, updated_at
        FROM events
        WHERE eventable_type IS NOT NULL AND eventable_id IS NOT NULL
        ORDER BY id
        LIMIT 1
      SQL
      recipient_message = "Historical direct message"
      mentioned_group_id = groups(:group).id
      connection.execute(<<~SQL.squish)
        UPDATE events
        SET custom_fields = custom_fields || jsonb_build_object(
          'recipient_message', #{connection.quote(recipient_message)},
          'group_ids', jsonb_build_array(#{connection.quote(mentioned_group_id)})
        )
        WHERE id = #{connection.quote(topic_item.fetch('id'))}
      SQL
      receipt_id = connection.select_value(<<~SQL.squish).to_i
        INSERT INTO notifications
          (event_id, user_id, actor_id, translation_values, viewed, created_at, updated_at)
        VALUES
          (#{connection.quote(topic_item.fetch('id'))}, #{connection.quote(users(:user).id)},
           #{connection.quote(topic_item.fetch('user_id'))}, '{}'::jsonb, TRUE,
           #{connection.quote(topic_item.fetch('created_at'))}, #{connection.quote(topic_item.fetch('updated_at'))})
        RETURNING id
      SQL
      NotificationConsolidationService.state(connection)
      connection.execute(<<~SQL.squish)
        UPDATE notification_consolidation_states
        SET notification_id_cursor = #{receipt_id},
            notification_id_high_water = #{receipt_id}
        WHERE name = '#{NotificationConsolidationService::STATE_NAME}'
      SQL

      stats = NotificationConsolidationService.run!(
        dry_run: false,
        high_water_id: receipt_id,
        repair: true
      )

      assert_equal 0, stats[:batches]
      assert_equal 1, stats.dig(:repair, :occurrences_inserted)
      assert_equal 1, stats.dig(:repair, :deliveries_inserted)
      assert_equal 0, stats.dig(:after, :missing_notifications)
      assert_equal 0, stats.dig(:after, :missing_deliveries)
      occurrence_message = connection.select_value(<<~SQL.squish)
        SELECT recipient_message
        FROM notification_occurrences
        WHERE legacy_event_id = #{connection.quote(topic_item.fetch('id'))}
      SQL
      assert_equal recipient_message, occurrence_message
      occurrence_audience = connection.select_value(<<~SQL.squish)
        SELECT audience_values
        FROM notification_occurrences
        WHERE legacy_event_id = #{connection.quote(topic_item.fetch('id'))}
      SQL
      assert_equal({ "group_ids" => [ mentioned_group_id ] }, JSON.parse(occurrence_audience))
      assert_not_nil stats.dig(:state, :completed_at)
      assert_not_nil stats.dig(:state, :repair_completed_at)
    end
  end

  test "cutover requires a completed low-ID repair sweep" do
    with_preparation_schema do |connection|
      NotificationConsolidationService.state(connection)
      connection.execute(<<~SQL.squish)
        UPDATE notification_consolidation_states
        SET completed_at = CURRENT_TIMESTAMP
        WHERE name = '#{NotificationConsolidationService::STATE_NAME}'
      SQL
      migration = CutOverEventsToTopicItems.new

      error = assert_raises(RuntimeError) do
        migration.send(:assert_notification_consolidation_complete!)
      end
      assert_match "low-ID repair sweep", error.message

      connection.execute(<<~SQL.squish)
        UPDATE notification_consolidation_states
        SET repair_completed_at = CURRENT_TIMESTAMP
        WHERE name = '#{NotificationConsolidationService::STATE_NAME}'
      SQL
      assert_nothing_raised do
        migration.send(:assert_notification_consolidation_complete!)
      end
    end
  end

  private

  def with_preparation_schema
    connection = ActiveRecord::Base.connection
    had_custom_fields = connection.column_exists?(:topic_items, :custom_fields)
    NotificationDelivery.delete_all
    Notification.delete_all

    connection.rename_table(:topic_items, :events)
    connection.rename_column(:events, :itemable_type, :eventable_type)
    connection.rename_column(:events, :itemable_id, :eventable_id)
    connection.rename_column(:events, :itemable_version_id, :eventable_version_id)
    connection.add_column(:events, :custom_fields, :jsonb, null: false, default: {}) unless had_custom_fields
    connection.change_column_null(:events, :topic_id, true)
    connection.rename_table(:notifications, :notification_occurrences)
    connection.add_column(:notification_occurrences, :legacy_event_id, :bigint, null: false)
    connection.add_index(
      :notification_occurrences,
      %i[legacy_event_id kind],
      unique: true,
      name: "index_notification_occurrences_on_legacy_event_and_kind"
    )
    connection.rename_column(:notification_deliveries, :notification_id, :notification_occurrence_id)
    connection.create_table(:notifications) do |t|
      t.bigint :event_id, null: false
      t.bigint :user_id, null: false
      t.bigint :actor_id
      t.jsonb :translation_values, null: false, default: {}
      t.boolean :viewed, null: false, default: false
      t.timestamps
    end
    connection.create_table(:notification_consolidation_states, id: false) do |t|
      t.string :name, null: false, primary_key: true
      t.bigint :notification_id_cursor, null: false, default: 0
      t.bigint :notification_id_high_water, null: false, default: 0
      t.datetime :completed_at
      t.datetime :repair_completed_at
      t.timestamps
    end

    yield connection
  ensure
    if connection&.data_source_exists?(:events)
      connection.drop_table(:notifications, if_exists: true)
      connection.drop_table(:notification_consolidation_states, if_exists: true)
      connection.remove_column(:notification_occurrences, :legacy_event_id)
      connection.rename_table(:notification_occurrences, :notifications)
      connection.rename_column(:notification_deliveries, :notification_occurrence_id, :notification_id)
      connection.execute("DELETE FROM events WHERE topic_id IS NULL")
      connection.change_column_null(:events, :topic_id, false)
      connection.rename_column(:events, :eventable_type, :itemable_type)
      connection.rename_column(:events, :eventable_id, :itemable_id)
      connection.rename_column(:events, :eventable_version_id, :itemable_version_id)
      connection.remove_column(:events, :custom_fields) unless had_custom_fields
      connection.rename_table(:events, :topic_items)
      TopicItem.reset_column_information
      Notification.reset_column_information
      NotificationDelivery.reset_column_information
    end
  end
end
