# Migration-owned cleanup for foreign keys introduced while Event and the
# legacy per-user Notification model still exist. Do not call current
# application models here: both are renamed later in this migration sequence.
module NotificationTaskUserIntegrityCleanup
  def self.run!(connection)
    delete_missing_polymorph(connection, :reactions, :reactable, "Stance", :stances)
    delete_missing_polymorph(connection, :bookmarks, :bookmarkable, "Stance", :stances)
    delete_missing_polymorph(connection, :tasks, :record, "Stance", :stances)
    delete_missing_polymorph(connection, :translations, :translatable, "Stance", :stances)
    delete_missing_polymorph(connection, :pg_search_documents, :searchable, "Stance", :stances)
    delete_missing_polymorph(connection, :active_storage_attachments, :record, "Stance", :stances)

    connection.execute(<<~SQL)
      DELETE FROM notifications
      WHERE NOT EXISTS (SELECT 1 FROM events WHERE events.id = notifications.event_id)
         OR NOT EXISTS (SELECT 1 FROM users WHERE users.id = notifications.user_id)
    SQL
    connection.execute(<<~SQL)
      DELETE FROM tasks_users
      WHERE NOT EXISTS (SELECT 1 FROM tasks WHERE tasks.id = tasks_users.task_id)
         OR NOT EXISTS (SELECT 1 FROM users WHERE users.id = tasks_users.user_id)
    SQL
  end

  def self.delete_missing_polymorph(connection, table, prefix, type, target_table)
    connection.execute(<<~SQL)
      DELETE FROM #{connection.quote_table_name(table)} records
      WHERE records.#{connection.quote_column_name("#{prefix}_type")} = #{connection.quote(type)}
        AND NOT EXISTS (
          SELECT 1
          FROM #{connection.quote_table_name(target_table)} targets
          WHERE targets.id = records.#{connection.quote_column_name("#{prefix}_id")}
        )
    SQL
  end
  private_class_method :delete_missing_polymorph
end
