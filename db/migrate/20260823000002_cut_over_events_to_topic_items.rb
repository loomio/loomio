class CutOverEventsToTopicItems < ActiveRecord::Migration[8.1]
  def up
    assert_notification_consolidation_complete!

    # The preparation release leaves this table under its legacy meaning: one
    # in-app receipt per user. Replace it only after the catch-up high-water mark
    # proves every receipt has been represented by a delivery.
    drop_table :notifications
    rename_table :notification_occurrences, :notifications
    rename_column :notification_deliveries,
                  :notification_occurrence_id,
                  :notification_id
    rename_column :notifications, :legacy_event_id, :topic_item_id
    change_column_null :notifications, :topic_item_id, true
    # Only a same-kind occurrence represents the timeline item itself. Mention
    # and other notifications may share its legacy event but remain independent.
    execute <<~SQL.squish
      UPDATE notifications
      SET topic_item_id = NULL
      FROM events
      WHERE notifications.topic_item_id = events.id
        AND (events.topic_id IS NULL OR notifications.kind IS DISTINCT FROM events.kind)
    SQL
    remove_index :notifications,
                 name: "index_notification_occurrences_on_legacy_event_and_kind"
    rename_index_if_present :notification_deliveries,
                            "index_notification_deliveries_on_occurrence_identity",
                            "index_notification_deliveries_on_identity"
    rename_index_if_present :notifications,
                            "index_notification_occurrences_pending_resolution",
                            "index_notifications_on_pending_delivery_resolution"

    execute "DELETE FROM events WHERE topic_id IS NULL"
    change_column_null :events, :topic_id, false
    change_column_null :events, :kind, false
    change_column_null :events, :eventable_type, false
    change_column_null :events, :eventable_id, false
    remove_column :events, :announcement
    rename_column :events, :eventable_type, :itemable_type
    rename_column :events, :eventable_id, :itemable_id
    rename_column :events, :eventable_version_id, :itemable_version_id
    rename_table :events, :topic_items
    add_check_constraint :topic_items,
                         "btrim(kind) <> ''",
                         name: "topic_items_kind_present"
    add_check_constraint :topic_items,
                         "btrim(itemable_type) <> ''",
                         name: "topic_items_itemable_type_present"

    add_index :notifications,
              :topic_item_id,
              unique: true,
              where: "topic_item_id IS NOT NULL",
              name: "index_notifications_on_topic_item_id"
    add_foreign_key :notifications,
                    :topic_items,
                    column: :topic_item_id,
                    on_delete: :nullify

    rename_index_if_present :topic_items, "index_events_on_created_at", "index_topic_items_on_created_at"
    rename_index_if_present :topic_items, "index_events_on_eventable_id_and_kind", "index_topic_items_on_itemable_id_and_kind"
    rename_index_if_present :topic_items, "index_events_on_eventable_type_and_eventable_id", "index_topic_items_on_itemable"
    rename_index_if_present :topic_items, "index_events_on_parent_id_and_topic_id", "index_topic_items_on_parent_id_and_topic_id"
    rename_index_if_present :topic_items, "index_events_on_parent_id", "index_topic_items_on_parent_id"
    rename_index_if_present :topic_items, "index_events_on_position_key", "index_topic_items_on_position_key"
    rename_index_if_present :topic_items, "index_events_on_topic_id_depth_sequence_id", "index_topic_items_on_topic_id_depth_sequence_id"
    rename_index_if_present :topic_items, "index_events_on_topic_id_and_sequence_id", "index_topic_items_on_topic_id_and_sequence_id"
    rename_index_if_present :topic_items, "index_events_on_topic_id_sequence_id_pinned", "index_topic_items_on_topic_id_sequence_id_pinned"
    rename_index_if_present :topic_items, "index_events_on_topic_id", "index_topic_items_on_topic_id"
    rename_index_if_present :topic_items, "index_events_on_user_id", "index_topic_items_on_user_id"
    rename_index_if_present :topic_items, "index_events_on_unique_discussion_created_event", "index_topic_items_on_unique_discussion_root"
    rename_index_if_present :topic_items, "index_events_on_unique_poll_created_event", "index_topic_items_on_unique_poll_root"

    drop_table :notification_consolidation_states
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "legacy per-user notification receipts were consolidated into deliveries"
  end

  private

  def assert_notification_consolidation_complete!
    legacy_notification_id_max = select_value("SELECT COALESCE(MAX(id), 0) FROM notifications").to_i
    state = select_one(<<~SQL.squish)
      SELECT notification_id_cursor, notification_id_high_water,
             completed_at, repair_completed_at
      FROM notification_consolidation_states
      WHERE name = 'legacy_notification_receipts'
    SQL

    unless state && state.fetch("completed_at").present?
      raise "cannot cut over notifications before consolidation completes"
    end
    unless state.fetch("repair_completed_at").present?
      raise "cannot cut over notifications before the low-ID repair sweep completes"
    end
    if state.fetch("notification_id_cursor").to_i < legacy_notification_id_max ||
       state.fetch("notification_id_high_water").to_i < legacy_notification_id_max
      raise "cannot cut over notifications: legacy receipts were written after the last catch-up sweep"
    end
  end

  def rename_index_if_present(table, old_name, new_name)
    return unless index_name_exists?(table, old_name)

    rename_index table, old_name, new_name
  end
end
