class ValidateNotificationTaskUserIntegrity < ActiveRecord::Migration[8.1]
  def up
    validate_foreign_key :notifications, :events, column: :event_id
    validate_foreign_key :notifications, :users, column: :user_id
    validate_foreign_key :tasks_users, :tasks, column: :task_id
    validate_foreign_key :tasks_users, :users, column: :user_id

    validate_check_constraint :notifications, name: "notifications_event_id_not_null"
    validate_check_constraint :notifications, name: "notifications_user_id_not_null"
    validate_check_constraint :tasks_users, name: "tasks_users_task_id_not_null"
    validate_check_constraint :tasks_users, name: "tasks_users_user_id_not_null"

    change_column_null :notifications, :event_id, false
    change_column_null :notifications, :user_id, false
    change_column_null :tasks_users, :task_id, false
    change_column_null :tasks_users, :user_id, false

    remove_check_constraint :notifications, name: "notifications_event_id_not_null"
    remove_check_constraint :notifications, name: "notifications_user_id_not_null"
    remove_check_constraint :tasks_users, name: "tasks_users_task_id_not_null"
    remove_check_constraint :tasks_users, name: "tasks_users_user_id_not_null"
  end

  def down
    change_column_null :tasks_users, :user_id, true
    change_column_null :tasks_users, :task_id, true
    change_column_null :notifications, :user_id, true
    change_column_null :notifications, :event_id, true
  end
end
