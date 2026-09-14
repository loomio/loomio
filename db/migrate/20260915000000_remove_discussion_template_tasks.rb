class RemoveDiscussionTemplateTasks < ActiveRecord::Migration[8.1]
  def up
    execute "DELETE FROM tasks WHERE record_type = 'DiscussionTemplate'"
  end

  def down
  end
end
