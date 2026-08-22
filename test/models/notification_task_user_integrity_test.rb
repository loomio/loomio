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

  test "database rejects a duplicate notification delivery key for one user" do
    event = events(:discussion_created_event)
    attrs = {
      event_id: event.id,
      user_id: @user.id,
      deduplication_key: "event:#{event.id}",
      created_at: Time.current,
      updated_at: Time.current
    }
    Notification.insert_all!([ attrs ])

    assert_raises(ActiveRecord::RecordNotUnique) do
      Notification.insert_all!([ attrs ])
    end
  end

  test "stored notification kind takes precedence over its event kind" do
    notification = Notification.new(event: events(:discussion_created_event))
    assert_equal "new_discussion", notification.kind

    notification.kind = "outcome_review_due"
    assert_equal "outcome_review_due", notification.kind
  end

  test "event fallback preserves announcement notification kinds" do
    event = Event.new(
      kind: "announcement_created",
      eventable: groups(:group),
      custom_fields: { "kind" => "poll_announced" }
    )

    assert_equal "poll_announced", Notification.new(event: event, user: @user).kind

    event.custom_fields = {}
    assert_equal "group_announced", Notification.new(event: event, user: @user).kind
  end

  test "event fallback preserves the user mention reply kind" do
    comment = comments(:public_discussion_comment)
    event = Event.new(kind: "user_mentioned", eventable: comment)

    assert_equal "comment_replied_to", Notification.new(event: event, user: comment.parent.author).kind
    assert_equal "user_mentioned", Notification.new(event: event, user: @user).kind
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
