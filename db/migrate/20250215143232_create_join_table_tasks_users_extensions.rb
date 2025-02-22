class CreateJoinTableTasksUsersExtensions < ActiveRecord::Migration[7.0]
  def change
    create_join_table :tasks, :users, table_name: :tasks_users_extensions, column_options: { foreign_key: true }

    add_column :tasks_users_extensions, :hidden, :boolean, default: false
    add_column :tasks_users_extensions, :id, :primary_key
    add_index :tasks_users_extensions,  [:task_id, :user_id], unique: true
  end
end
