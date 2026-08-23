require_relative "support/notification_task_user_integrity_cleanup"

class NormalizeNotificationTaskUserIntegrity < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    NotificationTaskUserIntegrityCleanup.run!(connection)

    add_foreign_key :notifications,
                    :events,
                    column: :event_id,
                    on_delete: :cascade,
                    validate: false,
                    if_not_exists: true
    add_foreign_key :notifications,
                    :users,
                    column: :user_id,
                    on_delete: :cascade,
                    validate: false,
                    if_not_exists: true
    add_foreign_key :tasks_users,
                    :tasks,
                    column: :task_id,
                    on_delete: :cascade,
                    validate: false,
                    if_not_exists: true
    add_foreign_key :tasks_users,
                    :users,
                    column: :user_id,
                    on_delete: :cascade,
                    validate: false,
                    if_not_exists: true

    add_check_constraint :notifications,
                         "event_id IS NOT NULL",
                         name: "notifications_event_id_not_null",
                         validate: false,
                         if_not_exists: true
    add_check_constraint :notifications,
                         "user_id IS NOT NULL",
                         name: "notifications_user_id_not_null",
                         validate: false,
                         if_not_exists: true
    add_check_constraint :tasks_users,
                         "task_id IS NOT NULL",
                         name: "tasks_users_task_id_not_null",
                         validate: false,
                         if_not_exists: true
    add_check_constraint :tasks_users,
                         "user_id IS NOT NULL",
                         name: "tasks_users_user_id_not_null",
                         validate: false,
                         if_not_exists: true
  end

  def down
    remove_check_constraint :tasks_users, name: "tasks_users_user_id_not_null", if_exists: true
    remove_check_constraint :tasks_users, name: "tasks_users_task_id_not_null", if_exists: true
    remove_check_constraint :notifications, name: "notifications_user_id_not_null", if_exists: true
    remove_check_constraint :notifications, name: "notifications_event_id_not_null", if_exists: true
    remove_foreign_key :tasks_users, column: :user_id, if_exists: true
    remove_foreign_key :tasks_users, column: :task_id, if_exists: true
    remove_foreign_key :notifications, column: :user_id, if_exists: true
    remove_foreign_key :notifications, column: :event_id, if_exists: true
  end
end
