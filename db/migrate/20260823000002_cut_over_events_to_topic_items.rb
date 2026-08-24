class CutOverEventsToTopicItems < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  BATCH_SIZE = 250_000

  def up
    consolidate_notifications!
    assert_notification_consolidation_complete!

    transaction do
      topic_ids_to_repair = topic_ids_affected_by_unpublishable_events

      # The preparation release leaves this table under its legacy meaning: one
      # in-app receipt per user. Replace it only after the catch-up high-water mark
      # proves every receipt has been represented by a delivery.
      drop_table :notifications
      rename_table :notification_occurrences, :notifications
      rename_column :notification_deliveries,
                    :notification_occurrence_id,
                    :notification_id
      remove_index :notifications,
                   name: "index_notification_occurrences_on_legacy_event_and_kind"
      # A publishable legacy Event becomes the notification's subject directly;
      # its itemable remains available through TopicItem#itemable.
      execute <<~SQL.squish
        UPDATE notifications
        SET subject_type = 'TopicItem',
            subject_id = events.id
        FROM events
        WHERE notifications.legacy_event_id = events.id
          AND NOT (#{unpublishable_event_condition('events')})
      SQL
      link_group_mentions_to_parent_topic_item_subjects!
      link_comment_notifications_to_topic_item_subjects!
      remove_column :notifications, :legacy_event_id
      rename_index_if_present :notification_deliveries,
                              "index_notification_deliveries_on_occurrence_identity",
                              "index_notification_deliveries_on_identity"
      rename_index_if_present :notifications,
                              "index_notification_occurrences_pending_resolution",
                              "index_notifications_on_pending_delivery_resolution"
      rename_index_if_present :notifications,
                              "index_notification_occurrences_on_subject",
                              "index_notifications_on_subject"

      # Preserve valid descendants if an old malformed event was used as their
      # parent. Topic repair reconstructs their ancestry from itemable records.
      execute <<~SQL.squish
        UPDATE events children
        SET parent_id = NULL, depth = 0
        FROM events parents
        WHERE children.parent_id = parents.id
          AND (#{unpublishable_event_condition('parents')})
      SQL
      execute "DELETE FROM events WHERE #{unpublishable_event_condition('events')}"
      change_column_null :events, :topic_id, false
      change_column_null :events, :kind, false
      change_column_null :events, :eventable_type, false
      change_column_null :events, :eventable_id, false
      remove_column :events, :announcement
      rename_column :events, :eventable_type, :itemable_type
      rename_column :events, :eventable_id, :itemable_id
      rename_column :events, :eventable_version_id, :itemable_version_id
      rename_table :events, :topic_items
      TopicItem.reset_column_information
      add_check_constraint :topic_items,
                           "btrim(kind) <> ''",
                           name: "topic_items_kind_present"
      add_check_constraint :topic_items,
                           "btrim(itemable_type) <> ''",
                           name: "topic_items_itemable_type_present"

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

      topic_ids_to_repair.each { |topic_id| TopicService.repair(topic_id) }
      drop_table :notification_consolidation_states
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "legacy per-user notification receipts were consolidated into deliveries"
  end

  private

  # Keep the normal upgrade path self-contained. Batches commit independently,
  # so rerunning db:migrate resumes after an interrupted deployment.
  def consolidate_notifications!
    require Rails.root.join("db/migrate/support/notification_consolidation_service")

    say_with_time "consolidating legacy notification receipts" do
      NotificationConsolidationService.run!(
        dry_run: false,
        batch_size: BATCH_SIZE,
        repair: true,
        progress: ->(cursor, high_water, _) { say "processed through #{cursor} of #{high_water}", true }
      )
    end
  end

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

  def topic_ids_affected_by_unpublishable_events
    select_values(<<~SQL.squish).map(&:to_i)
      SELECT DISTINCT topic_id
      FROM (
        SELECT events.topic_id
        FROM events
        WHERE #{unpublishable_event_condition('events')}
        UNION ALL
        SELECT children.topic_id
        FROM events children
        INNER JOIN events parents ON parents.id = children.parent_id
        WHERE #{unpublishable_event_condition('parents')}
      ) affected
      WHERE topic_id IS NOT NULL
    SQL
  end

  # Legacy mention and reply receipts referenced their own topicless events.
  # Point them directly at the subject comment's durable new_comment item.
  def link_comment_notifications_to_topic_item_subjects!
    execute <<~SQL.squish
      UPDATE notifications
      SET subject_type = 'TopicItem',
          subject_id = comment_items.id
      FROM events comment_items
      WHERE notifications.kind IN ('user_mentioned', 'comment_replied_to', 'group_mentioned')
        AND notifications.subject_type = 'Comment'
        AND comment_items.kind = 'new_comment'
        AND comment_items.eventable_type = 'Comment'
        AND comment_items.eventable_id = notifications.subject_id
        AND comment_items.topic_id IS NOT NULL
    SQL
  end

  # Group-mention events retained the exact initiating event as their parent.
  # Preserve that occurrence when the parent is a publishable timeline item.
  def link_group_mentions_to_parent_topic_item_subjects!
    execute <<~SQL.squish
      UPDATE notifications
      SET subject_type = 'TopicItem',
          subject_id = parent_events.id
      FROM events mention_events
      INNER JOIN events parent_events ON parent_events.id = mention_events.parent_id
      WHERE notifications.kind = 'group_mentioned'
        AND notifications.legacy_event_id = mention_events.id
        AND NOT (#{unpublishable_event_condition('parent_events')})
    SQL
  end

  def unpublishable_event_condition(table)
    <<~SQL.squish
      #{table}.topic_id IS NULL OR
      #{table}.kind IS NULL OR btrim(#{table}.kind) = '' OR
      #{table}.eventable_type IS NULL OR btrim(#{table}.eventable_type) = '' OR
      #{table}.eventable_id IS NULL
    SQL
  end

  def rename_index_if_present(table, old_name, new_name)
    return unless index_name_exists?(table, old_name)

    rename_index table, old_name, new_name
  end
end
