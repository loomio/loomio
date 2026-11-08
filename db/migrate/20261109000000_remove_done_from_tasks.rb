# done_at now records whether a task is done. Reconcile rows where the two
# columns disagreed before dropping done: a done task without a completion time
# takes its last update time, and an open task loses a stale completion time.
class RemoveDoneFromTasks < ActiveRecord::Migration[8.1]
  def up
    execute "SET LOCAL lock_timeout = '1s'"
    execute "UPDATE tasks SET done_at = updated_at WHERE done AND done_at IS NULL"
    execute "UPDATE tasks SET done_at = NULL WHERE NOT done AND done_at IS NOT NULL"
    remove_index :tasks, :done
    remove_column :tasks, :done
  end

  def down
    execute "SET LOCAL lock_timeout = '1s'"
    add_column :tasks, :done, :boolean, null: false, default: false
    execute "UPDATE tasks SET done = (done_at IS NOT NULL)"
    change_column_default :tasks, :done, nil
    add_index :tasks, :done
  end
end
