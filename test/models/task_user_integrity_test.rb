require "test_helper"

class TaskUserIntegrityTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
  end

  test "database rejects task user rows without a task" do
    assert_raises(ActiveRecord::InvalidForeignKey) do
      TasksUser.insert_all!([ {
        task_id: (Task.maximum(:id) || 0) + 100,
        user_id: @user.id,
        created_at: Time.current,
        updated_at: Time.current
      } ])
    end
  end

  test "deleting a task cascades to task user rows" do
    task = Task.create!(name: "Test task", author: @user, done: false, uid: 1)
    task_user = TasksUser.create!(task: task, user: @user)

    Task.where(id: task.id).delete_all

    assert_not TasksUser.exists?(task_user.id)
  end
end
