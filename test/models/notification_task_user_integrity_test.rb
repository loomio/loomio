require "test_helper"

class NotificationTaskUserIntegrityTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
  end

  test "database rejects notifications without an event" do
    assert_raises(ActiveRecord::InvalidForeignKey) do
      Notification.insert_all!([ {
        event_id: Event.maximum(:id) + 100,
        user_id: @user.id,
        created_at: Time.current,
        updated_at: Time.current
      } ])
    end
  end

  test "deleting an event cascades to notifications" do
    event = Event.create!(eventable: groups(:group), user: @user, kind: "announcement_created")
    notification = Notification.create!(event: event, user: @user, actor: @user)

    Event.where(id: event.id).delete_all

    assert_not Notification.exists?(notification.id)
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
